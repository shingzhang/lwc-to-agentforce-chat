# Fixture: HTML product card prototype

Fully fictional. No real customer.

## Scenario

You have a plain-HTML prototype of a product card that a designer prototyped in a static-site generator. You want to convert it into an LWC that renders inside an Agentforce chat bubble.

## Using this fixture

In a Claude Code session inside the plugin repo:

```
> I have an HTML prototype for a chat card
```

When the skill asks for the HTML source, point at `fixtures/example-html/product-card.html`.

The skill will run the 8 transforms from `references/html-to-lwc-transforms.md` and produce a 4-file LWC bundle preview.

## Expected transforms applied

- Transform 1: `onclick="handleAddToBag('SKU-42')"` → `onclick={handleAddToBag}` + generated handler
- Transform 2: `onchange="handleQtyChange(this.value)"` → `onchange={handleQtyChange}` + handler
- Transform 3: External `<img src="https://cdn.example.com/...">` → `<img src={imageUrl}>` + CspTrustedSite scaffold
- Transform 4: `style="color: #6B8E4E"` inline → moved to `.css` sibling with class

## What happens next

The skill emits the 4-file LWC bundle preview (`.js`, `.html`, `.css`, `.js-meta.xml`), asks YES to write, then continues Entry 2 Steps 6-11 (naming, DTO, LightningType, Invocable, Agent Script, deploy checkpoint).
