# HTML → LWC Transformations — reference

When Entry point 2 fires (user has an HTML/CSS prototype), the skill runs these 8 transforms in order. Each transform is teachable — the What/Why/Next micro-block cites the transform by number so the user learns *why* the change is needed, not just *that* it happened.

Transforms 1–8 are applied to the source HTML in sequence. The three "receiving wrapper" additions (§ **The receiving wrapper**) come after, once the LWC template is clean. The end-to-end example at the bottom shows all four files (`.html`, `.css`, `.js`, `.js-meta.xml`) side-by-side.

## The 8 transforms

### Transform 1: Event handler binding

- **What**: Rewrite HTML event attributes so their value is a method reference, not an inline call.
- **Why**: The LWC compiler binds handlers as method references at parse time. Parens would trigger eval, and LWC deliberately disallows expression evaluation in templates.

**Before**
```html
<button onclick="handleClick()">Save</button>
```

**After**
```html
<button onclick={handleClick}>Save</button>
```

- **Gotchas**:
  - `onclick="fn(this)"` — the `this` argument has no LWC equivalent. Change to `onclick={fn}` and read `event.target` inside the method body.
  - Handler names must exist as class methods on the component. If the source had inline logic (`onclick="alert('x')"`), extract it into a named method first.
- **Failure mode**: none in `experience-cloud-site-builder` §C — the LWC compiler catches this at build time with a clear error.

---

### Transform 2: Input event binding

- **What**: Rewrite input events that read `this.value` inline, and generate a wrapper method that pulls the value from `event.target`.
- **Why**: Same rule as Transform 1 (no eval in templates), plus LWC events don't preserve the `this` context of the source element.

**Before**
```html
<input type="text" onchange="handleQuantityChange(this.value)">
```

**After**
```html
<input type="text" onchange={handleQuantityChange}>
```

```js
handleQuantityChange(event) {
    const v = event.target.value;
    // …existing logic that took `this.value` as an argument…
}
```

- **Gotchas**:
  - `onblur`, `onfocus`, `oninput`, `onkeydown`, `onkeyup` all follow the same pattern.
  - `<select onchange="...">` and `<textarea oninput="...">` need the same treatment.
- **Failure mode**: none in §C — compile-time error.

---

### Transform 3: Image src binding

- **What**: Rewrite `<img src>` references so relative paths and external URLs both flow through the component's JavaScript, and register any external host with a `CspTrustedSite`.
- **Why**: LWC runs inside a Locker Service / Lightning Web Security sandbox that cannot resolve relative filesystem paths. Every asset either ships as a static resource (`@salesforce/resourceUrl/<name>`) or lives at an approved external host. Unapproved hosts get blocked by CSP with no visible error.

**Before**
```html
<img src="./local.png" alt="">
<img src="https://assets.example.com/products/coffee-maker.jpg" alt="">
```

**After**
```html
<img src={localImageUrl} alt="">
<img src={productImageUrl} alt="">
```

```js
import PRODUCT_IMG from '@salesforce/resourceUrl/localProductImage';

localImageUrl = PRODUCT_IMG;
productImageUrl = 'https://assets.example.com/products/coffee-maker.jpg';
```

Plus `force-app/main/default/cspTrustedSites/Assets_Example_Com.cspTrustedSite-meta.xml` if any external host is referenced.

- **Gotchas**:
  - `alt=""` is required even for decorative images; failure to set `alt` breaks a11y and Failure Mode #8 sometimes masks itself as an a11y issue.
  - Handling image load failure: hide broken images (`event.target.style.display = 'none'`) rather than falling back to a placeholder URL — a placeholder that also 404s creates a broken-image loop.
- **Failure mode**: `experience-cloud-site-builder` §C **Failure Mode #8 — Card renders, images blank.** Fix in v1 skill.

---

### Transform 4: Inline styles

- **What**: Move `style="..."` attributes to classes, and move the corresponding CSS declarations to a `.css` sibling file.
- **Why**: LWC uses shadow DOM by default. Inline styles work, but external stylesheets don't reach inside the component. Scoped CSS in a sibling `.css` file is the LWC convention and the only reliable path.

**Before**
```html
<div style="color:#C41E3A; padding:12px;">Featured</div>
```

**After**
```html
<div class="featured-heading">Featured</div>
```

```css
/* shoppingCarousel.css */
.featured-heading {
    color: #C41E3A;
    padding: 12px;
}
```

- **Gotchas**:
  - CSS custom properties (`--my-color: red;`) *do* cross the shadow boundary — safe to use.
  - `!important` doesn't help you punch through the shadow boundary; it just makes the CSS harder to override later.
- **Failure mode**: none directly — but skipping this transform makes theming impossible downstream (customer branding changes have to touch every component instead of a shared stylesheet).

---

### Transform 5: Script tags

- **What**: Strip `<script>` tags from the source; port their logic into methods on the component's `export default class` in `.js`.
- **Why**: LWC compiles `.js` files as ES modules. Templates (`.html`) are pure markup — script tags are not allowed, and the compiler will reject them.

**Before**
```html
<script>
    function initCarousel() {
        const el = document.querySelector('.carousel');
        el.addEventListener('scroll', updateActiveIndex);
    }
    window.addEventListener('load', initCarousel);
</script>
```

**After**
```js
import { LightningElement } from 'lwc';

export default class ShoppingCarousel extends LightningElement {
    connectedCallback() {
        // Called after component inserted into DOM — LWC's equivalent of `load`.
    }

    renderedCallback() {
        const el = this.template.querySelector('.carousel');
        if (el && !el.__scrollBound) {
            el.__scrollBound = true;
            el.addEventListener('scroll', this.updateActiveIndex.bind(this));
        }
    }

    updateActiveIndex(event) {
        // …
    }
}
```

- **Gotchas**:
  - `document.querySelector` becomes `this.template.querySelector` — the shadow DOM boundary means `document` can't see inside the component.
  - `window.addEventListener('load', ...)` becomes the `connectedCallback` lifecycle hook.
  - Use a single `connectedCallback` per file. Duplicating it silently overrides the earlier definition — the classic Failure Mode #10 shape.
- **Failure mode**: `experience-cloud-site-builder` §C **Failure Mode #10 — Card mounts, value populated, template renders blank** (when a duplicate `connectedCallback` overrides the one that runs your parse logic).

---

### Transform 6: Conditional rendering

- **What**: Replace JS-templated `if (foo) { ... }` blocks with LWC's `<template lwc:if={foo}>` directive.
- **Why**: LWC templates are declarative — no expressions, no ternaries, no JS operators. Conditionals are directive-based.

**Before** (Handlebars-style or JSX-style pseudo-template)
```html
{{#if hasProducts}}
    <ul>{{#each products}}<li>{{name}}</li>{{/each}}</ul>
{{else}}
    <p>No products found.</p>
{{/if}}
```

**After**
```html
<template lwc:if={hasProducts}>
    <ul>
        <template for:each={products} for:item="p">
            <li key={p.id}>{p.name}</li>
        </template>
    </ul>
</template>
<template lwc:else>
    <p>No products found.</p>
</template>
```

- **Gotchas**:
  - Older LWC used `if:true={foo}` and `if:false={foo}`. Both still work but `lwc:if` / `lwc:elseif` / `lwc:else` is the current convention — prefer it for anything new.
  - You cannot write `lwc:if={!foo}` — no `!` operator in templates. Add an inverse getter: `get hasNoProducts() { return !this.hasProducts; }` and use `<template lwc:if={hasNoProducts}>`.
- **Failure mode**: none in §C, but skipping this transform produces a template parse error at build time.

---

### Transform 7: Loops

- **What**: Rewrite iteration to LWC's `<template for:each>` directive, and add a `key` attribute to every iterated element.
- **Why**: LWC's virtual-DOM diffing algorithm requires a stable key per list item; without it, LWC re-renders every item on every data change instead of just the ones that changed. On chat surfaces with 380px cards and images, that's visible jank.

**Before**
```html
{{#each products as product}}
    <div class="card">
        <img src="{{product.image}}" alt="">
        <p>{{product.name}}</p>
    </div>
{{/each}}
```

**After**
```html
<template for:each={products} for:item="product">
    <div key={product.id} class="card">
        <img src={product.image} alt="">
        <p>{product.name}</p>
    </div>
</template>
```

- **Gotchas**:
  - The iteration variable (`for:item="product"`) is scoped to the template block. Nested `for:each` loops need distinct names (`for:item="row"` outside, `for:item="cell"` inside).
  - `for:index="i"` gives you the numeric index if needed.
  - `key` must be unique within the loop. If the data has no natural ID, generate one at parse time (e.g., in the `@api value` setter) rather than falling back to array index — index keys defeat the whole point of the diff.
- **Failure mode**: none directly — but skipping the `key` attribute manifests as list jitter and lost scroll position when items update.

---

### Transform 8: Dynamic class strings

- **What**: Replace string-concatenated `class="..."` expressions with a getter that returns the computed class name.
- **Why**: LWC templates don't allow expressions in attribute values. `class="foo {isActive ? 'active' : ''}"` won't parse. The template can only reference a bound value.

**Before**
```html
<div class="card {{isActive ? 'active' : ''}} tier-{{tier}}">…</div>
```

**After**
```html
<div class={cardClass}>…</div>
```

```js
get cardClass() {
    const base = 'card';
    const active = this.isActive ? 'active' : '';
    const tierClass = `tier-${this.tier}`;
    return [base, active, tierClass].filter(Boolean).join(' ');
}
```

- **Gotchas**:
  - Getters re-evaluate whenever *tracked* fields they read change. If `isActive` is a plain field (not `@track` on nested objects), the getter may not fire on mutation — mutate by reassignment (`this.isActive = true`) rather than by property change on a nested object.
  - For simple two-state toggles, prefer `classList` manipulation in `renderedCallback` or a computed boolean prop combined with the `lwc:if` pattern.
- **Failure mode**: none in §C — but a stale getter that never re-evaluates looks a lot like Failure Mode #9 ("Card mounts, `value` is `undefined`") if the getter itself depends on `value`.

---

## The receiving wrapper

Once the 8 transforms are applied, the LWC that renders in chat needs three additional pieces beyond a "normal" LWC:

1. **`@api value` getter/setter** — a reactive pattern that re-parses the incoming DTO on every update. A plain `@api value;` prop reads once at mount and never reacts to updates from the chat client. This is `experience-cloud-site-builder` §C **Failure Mode #9 — Card mounts, value populated, template renders blank** (or `undefined`) if the setter isn't wired.

2. **`.js-meta.xml` targets** — the target list must include `<target>lightning__AgentforceOutput</target>`. Without this target, the chat surface can't mount the component at all.

3. **`<targetConfigs>` binding** — inside `.js-meta.xml`, add a `<targetConfigs>` block with `<sourceType name="c__<LightningTypeFolder>"/>` so the chat client knows which Lightning Type resolves to this LWC. Missing this binding causes `experience-cloud-site-builder` §C **Failure Mode #12 — `areGuestUsersAllowed` silently blocks the card renderer** (misleading name — the real cause is often the missing sourceType binding).

The end-to-end example below shows all three.

---

## Example — end-to-end

Source HTML (a product card with a click handler, an image, an inline style, and a conditional):

```html
<div style="border-radius:8px; padding:12px;">
    <img src="https://assets.example.com/coffee.jpg" alt="">
    <p>Coffee Maker — $89</p>
    {{#if inStock}}<button onclick="addToBag(this.dataset.id)" data-id="123">Add</button>{{/if}}
</div>
```

**After (four files):**

```html
<!-- productCard.html -->
<template>
    <div class="card">
        <img src={imageUrl} alt="">
        <p>{name} — {price}</p>
        <template lwc:if={inStock}>
            <button onclick={handleAdd}>Add</button>
        </template>
    </div>
</template>
```

```css
/* productCard.css */
.card { border-radius: 8px; padding: 12px; }
```

```js
// productCard.js
import { LightningElement, api } from 'lwc';

export default class ProductCard extends LightningElement {
    _value;
    @api get value() { return this._value; }
    set value(v) {
        this._value = v;
        try {
            const raw = typeof v === 'string' ? JSON.parse(v) : (v?.productJSON ? JSON.parse(v.productJSON) : v);
            this.name = raw?.name;
            this.price = raw?.price;
            this.imageUrl = raw?.image;
            this.inStock = !!raw?.inStock;
            this.productId = raw?.id;
        } catch (e) { console.error('#### productCard parse error:', e); }
    }

    name; price; imageUrl; inStock = false; productId;

    handleAdd() {
        this.dispatchEvent(new CustomEvent('addtobag', { detail: { id: this.productId } }));
    }
}
```

```xml
<!-- productCard.js-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <isExposed>true</isExposed>
    <masterLabel>Product Card</masterLabel>
    <targets>
        <target>lightning__AgentforceOutput</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__AgentforceOutput">
            <sourceType name="c__Product_Card"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

Transforms exercised: **1** (`onclick` binding on `<button>`), **3** (external image src + implied `CspTrustedSite`), **4** (inline `style` → `.card` class in `.css`), **6** (`{{#if}}` → `<template lwc:if>`). Plus all three receiving-wrapper additions.

---

## Cross-references

- **REQUIRED:** `experience-cloud-site-builder` Phase 2 Piece 3 — the full LWC bundle contract, including the reactive `@api value` pattern, the anti-patterns (single `connectedCallback`, image error handling), and the exact `.js-meta.xml` shape.
- **RECOMMENDED:** `generating-lwc-components` — a11y patterns (labels, focus management, keyboard nav), Jest test scaffolding, wire adapter patterns, and any LWC concern beyond these 8 transforms.
