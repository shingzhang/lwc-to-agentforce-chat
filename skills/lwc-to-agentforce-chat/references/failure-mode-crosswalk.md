# Failure-Mode Crosswalk — reference

Fast lookup from a symptom the user reports (or a state this skill detects during a build) to a numbered Failure Mode. This skill tracks 17 numbered failure modes plus a "bonus" entry; this file is the catalog.

Teaching blocks in `SKILL.md` **never restate the full fix inline**. They cite the number, print a one-line diagnosis, and offer `R=details on Failure Mode #N` so the user can jump to the full write-up below. That keeps each teaching block short without losing the detail — everything is in this file, not off in a skill the reviewer may not have installed.

## Full crosswalk table

| Symptom / What the user sees | Detected at | FM # | One-line diagnosis |
|---|---|---|---|
| First user message triggers no reply; conversation ends with no error | Entry 3 Step 5 (missing `variables:` block); Deploy checkpoint | **1** | `.agent` file missing `EndUserId` / `RoutableId` / `ContactId` / `EndUserLanguage` linked-string variables |
| Chat surface loads but hangs on "Connecting to agent..." | Deploy checkpoint (post-deploy verify); Entry 4 org scan | **2** | Channel `RoutingType` not `null` or bot user missing permset assignment via `--on-behalf-of` |
| Agent's welcome message arrives after the user's first utterance | Entry 1/2 Step 11 (Deploy checkpoint); manual UI review | **3** | ECV2 `bootstrap.init()` racing with utterance-send; timing / event-order bug |
| Console shows `Uncaught TypeError: sendTextMessage is undefined` | Entry 1 Step 11 (Deploy checkpoint) | **4** | Embedded Service SDK not loaded before wrapper LWC mounts; script tag order wrong |
| Chat renders as bottom-right floating FAB, not inline | Entry 1 Step 5 (mode selection); Deploy verify | **5** | Wrapper LWC missing `displayMode: 'inline'` in `bootstrap.init()` config |
| ECV2 host div exists in DOM but iframe never renders inside it | Entry 1 Step 11; DL-08 cross-check | **6** | Guest user permset missing on the ESW backing site, or `areGuestUsersAllowed=false` |
| Agent reply is plain text/JSON instead of the branded card | Entry 1/2 Step 10 (Piece 5 write); Entry 3 Step 5 | **7** | `.agent` output missing `is_displayable: True` and/or `complex_data_type_name: "c__<Folder>"` |
| Card renders but product/asset images are blank | Entry 1 Step 4 (external host); Entry 2 Transform 3; Deploy verify | **8** | External image host not in `CspTrustedSite` metadata |
| Card mounts but `this.value` is `undefined` in LWC | Entry 3 Step 6 (@api value patch); Entry 1/2 Piece 3 write | **9** | LWC uses plain `@api value` prop instead of reactive getter/setter |
| Card mounts, `value` is populated, but template renders blank | Entry 2 Transform + Piece 3 write; Entry 3 Step 6 | **10** | Duplicate `connectedCallback` in `.js`; second definition shadows the JSON-parse hook |
| ECV2 agent header still visible after chrome hide | Entry 1 Step 5 (mode B/C only) | **11** | `.embedded-messaging` CSS overrides missing or overridden by SLDS `*` reset |
| Chat closes; console shows no error; SSE stream terminates | Entry 3 Step 7 (`.js-meta.xml` verify); Deploy checkpoint | **12** | `.js-meta.xml` `<targetConfigs>` block missing or `sourceType name` doesn't match `.agent` `complex_data_type_name` |
| Runtime error: `insufficient access rights on cross-reference id` | Deploy checkpoint step 7 (`sf org assign permset`); Entry 4 org scan | **13** | Permission set assigned to CLI user or admin, not to the bot user (needs `--on-behalf-of <botUser>`) |
| Contextual wizard panel opens on first query but not on second | Entry 1 Step 6 (Mode B contextual panel); Deploy verify | **14** | postMessage bridge listener attached once at mount; needs re-attach on each session |
| Local state canvas breaks after `sf project retrieve` | Entry 3 Step 2 (state detection); Entry 4 scan | **15** | Retrieve overwrote local `.js-meta.xml` `<targetConfigs>` block with org's older shape |
| `sf project deploy start` fails: `Schema update contains breaking changes` | Deploy checkpoint | **16** | LightningType `schema.json` changed after being referenced by a deployed `.agent`; requires deactivate + republish sequence |
| ESD Publish returns `Something went wrong, Gack ID: XXX-YYY (-N)` | Manual UI republish step | **17** | Transient async race on Publish endpoint; retry with 30–60s waits, up to 5 attempts |
| Agent Builder Preview renders card, but Test Enhanced Chat (live ECV2) shows plain text | Entry 1 Step 11 diagnostic; user reports post-deploy | **Bonus** | Preview uses in-app render path; live chat uses ECV2's separate resolver that requires the LightningType to be fully deployed + ESD republished |

## Full write-ups — the 5 failure modes this skill checks proactively

The table above is a fast index for every failure mode. These five are the ones `references/html-to-lwc-transforms.md` and `SKILL.md` actively check for at transform time and during the 5-piece contract writes, so they get the full fix here instead of a one-liner.

### Failure Mode #7 — Card replaced by text

**Symptom:** The agent's reply arrives as plain text or raw JSON instead of the branded card.

**Cause:** The `.agent` action's displayable output is missing one or both of the two lines that tell the chat surface to mount a Lightning Type instead of printing the raw value: `is_displayable: True` and `complex_data_type_name: "c__<LightningTypeFolder>"`.

**Fix:** Add both lines to the output that should render, and make sure the folder name matches the deployed LightningType exactly, `c__` prefix included:
```yaml
outputs:
  carousel:
    type: String
    is_displayable: True
    complex_data_type_name: "c__Retail_ShoppingCarousel"
```

**Verify:** Re-publish and re-activate the agent bundle, then re-test. If it still prints text, check for a typo in the folder name — `complex_data_type_name` has to match the LightningType's developer name exactly, case-sensitive.

### Failure Mode #8 — Card renders, images blank

**Symptom:** The card layout is correct but product/asset images never load — no error in the console, just an empty box where the image should be.

**Cause:** LWC's Lightning Web Security sandbox blocks any external image host that isn't on the org's CSP allowlist. The request gets silently dropped; there's rarely a visible network error.

**Fix:** Add the host to `CspTrustedSite`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<CspTrustedSite xmlns="http://soap.sforce.com/2006/04/metadata">
    <endpointUrl>https://assets.example.com</endpointUrl>
    <isActive>true</isActive>
    <context>All</context>
</CspTrustedSite>
```
Deploy it under `force-app/main/default/cspTrustedSites/`. Also add a load-failure handler so a still-blocked image degrades to nothing instead of a broken-image icon: `event.target.style.display = 'none'` on the `<img>`'s `onerror`.

**Verify:** Hard-refresh the chat surface (CSP changes can be cached client-side) and confirm the image loads. If it still doesn't, check the exact host in the network tab — CDNs often serve from a subdomain that isn't the one registered.

### Failure Mode #9 — Card mounts, `value` populated, template renders blank or `undefined` (missing reactive setter)

**Symptom:** The LightningType resolves and the card mounts, but its fields read as `undefined` or the template shows nothing.

**Cause:** The LWC declared `@api value;` as a plain reactive property. That renders fine on the first paint, but the chat client re-sends `value` on every conversation turn, and a plain `@api` property doesn't re-run any parsing logic on reassignment — nothing re-derives the fields the template actually reads.

**Fix:** Replace the plain property with a getter/setter pair that re-parses on every set:
```js
_value;
@api get value() { return this._value; }
set value(v) {
    this._value = v;
    try {
        const raw = typeof v === 'string' ? JSON.parse(v) : (v?.productsJSON ? JSON.parse(v.productsJSON) : v);
        this.name = raw?.name;
        this.price = raw?.price;
        this.imageUrl = raw?.image;
    } catch (e) {
        console.error('#### parse error:', e);
    }
}
```

**Verify:** Log inside the setter and confirm it fires more than once across a multi-turn conversation, not just at mount.

### Failure Mode #10 — Card mounts, `value` populated, template renders blank (duplicate `connectedCallback`)

**Symptom:** Same visible symptom as #9 — a blank template — but the `@api value` setter above is correct and still fires.

**Cause:** The `.js` file has two `connectedCallback()` definitions, usually left over from a copy-paste during the script-tag transform (Transform 5). JavaScript class bodies silently let the second definition shadow the first; whichever one ran the JSON-parse hook is now gone.

**Fix:** Search the file for `connectedCallback` and merge into one method. If two lifecycle concerns both needed it, combine their bodies:
```js
connectedCallback() {
    this._initTracking();
    this._parseInitialValue();
}
```

**Verify:** `grep -c "connectedCallback(" <file>.js` should return `1`.

### Failure Mode #12 — Missing or mismatched `targetConfigs` binding

**Symptom:** The chat closes with no console error, or the SSE stream just terminates without ever mounting the card.

**Cause:** `.js-meta.xml` lists the `lightning__AgentforceOutput` target, but has no `<targetConfigs>` block, or the block's `<sourceType name="...">` doesn't match the LightningType folder's developer name. Without this binding the chat client has no way to resolve which LWC a given Lightning Type should render as. The symptom can look like a permissions issue — it usually isn't.

**Fix:**
```xml
<targetConfigs>
    <targetConfig targets="lightning__AgentforceOutput">
        <sourceType name="c__Retail_ShoppingCarousel"/>
    </targetConfig>
</targetConfigs>
```
The `name` attribute must match the `.lightningTypeBundle-meta.xml` folder name exactly, `c__` prefix included.

**Verify:** Re-deploy the LWC and LightningType together — they reference each other, and deploying only one is a common trigger for this failure — then re-test the chat surface.

## Detection hooks per entry point

**Entry 1 (Figma → LWC)** — proactive checks:
- FM #8 at Step 4: if the extracted Brand Summary includes image URLs from a host not already in `CspTrustedSite`, warn.
- FM #9 at Step 8 (Piece 3 LWC write): assert `@api value` getter/setter, not plain prop.
- FM #12 at Step 8 (Piece 3 `.js-meta.xml` write): assert `<targetConfigs>` block binds `sourceType name` to the LightningType folder.
- FM #7 at Step 10 (Piece 5 `.agent` write): assert `is_displayable: True` AND `complex_data_type_name: "c__<Folder>"`.

**Entry 2 (HTML → LWC)** — proactive checks:
- FM #10 at Transform 5 (script tags → .js): assert single `connectedCallback`; refuse duplicate.
- FM #9 at Piece 3 wrap: same as Entry 1.
- FM #12 at `.js-meta.xml` emit: same as Entry 1.
- FM #8 at Transform 3 (image src): flag external hosts; recommend `CspTrustedSite`.

**Entry 3 (Existing LWC)** — state detection at Step 2 catches all of these upfront:
- FM #7 (missing displayable output in `.agent`)
- FM #9 (missing reactive `@api value` in `.js`)
- FM #10 (duplicate `connectedCallback` in `.js`)
- FM #12 (missing `<targetConfigs>` in `.js-meta.xml`)
- FM #13 (permset not assigned to bot user)

**Entry 4 (Scan)** — no direct FM checks. Funnels to Entry 1/2/3, whose checks fire in-path.

## The `R=details on Failure Mode #N` handler

When the user types `R` after the skill has just cited `Failure Mode #<N>` in a teaching block:

1. Find `Failure Mode #<N>` in this file. #7, #8, #9, #10, and #12 have a full write-up above (symptom, cause, fix, verify). The rest have the one-line diagnosis in the crosswalk table.
2. Print the entry **verbatim**. Do not summarize.
3. Print a return prompt: "Reply with the next step number, or paste new state to continue."

If the user types `R` and no FM has been cited in the immediately preceding message:

> Nothing cited yet. I'll surface `R` inline whenever I reference a specific Failure Mode.
