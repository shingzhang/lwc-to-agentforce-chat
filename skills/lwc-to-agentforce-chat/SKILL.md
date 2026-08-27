---
name: lwc-to-agentforce-chat
description: >
  Turn a Figma design into a Lightning Web Component that renders inside an
  Agentforce chat bubble, with a mandatory HTML preview step in the middle so
  you can review the design in a browser before it becomes LWC. Guides and
  teaches at every step: what's happening, why it matters, and where you are.

  TRIGGER when: user has a Figma URL / Figma export / PNG mockup and wants it
  rendered inside Agentforce chat; user asks "how do I get this design into a
  chat card"; user says "turn this Figma into an in-chat LWC"; user wants an
  LWC in an agent response bubble.

  DO NOT TRIGGER when: user only has HTML with no Figma source (this version is
  Figma-first — bring the design); user wants an LWC on an Experience Builder
  page rather than in a chat bubble; user is only auditing an existing build
  with no changes planned; user is authoring the Custom Lightning Type schema
  from scratch (use generating-custom-lightning-type first, then return here);
  user has zero Salesforce context (start with developing-agentforce for
  agent-first work).
license: MIT
experimental: true
metadata:
  version: "0.4.3"
  last_updated: "2026-08-26"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
---

# lwc-to-agentforce-chat — Figma → HTML preview → LWC

This skill is a **single, linear walkthrough** with a teaching layer. There is exactly one path: Figma → HTML prototype (preview + review) → LWC bundle → 5-piece contract → deploy checkpoint.

It has three sections:

- **§A Guided Flow** — the walkthrough. Start here. Always.
- **§B Phase Playbooks** — reference material each §A step consults, not a linear script.
- **§C Reference** — the What/Why/Next teaching-block template, progress-label rules, failure-mode crosswalk.

If you are Claude and you have opened this skill, do NOT dump §B or §C at the user. Follow §A. Cite §B / §C by phase/section number when needed.

The skill's core promise is **guiding + teaching + a real design-review moment**. Every substantive action produces a three-line What / Why / Next block (see §C or `references/teaching-blocks.md`). The Step 3 HTML preview is the load-bearing review checkpoint — the design becomes browser-viewable HTML before any LWC bundle is generated.

---

# §A — Guided Flow

## Ground rules (always in force)

- Keep commentary short: **1–3 sentences between menus**. No hype, no filler, no "Great question!" / "Perfect!" / "Absolutely" / "I'd love to help."
- Ask **exactly one question at a time** unless summarizing.
- **Never write files under `force-app/` or run deploys without explicit YES.** Preview → confirm → write.
- **The HTML preview step (Step 3) is mandatory and non-skippable.** The user reviews the intermediary HTML in a browser (or as rendered markup) before any LWC transform runs.
- Standing options unlock progressively (see "Standing options" below). The opening prompt shows no `C/S/R/V/E` block. From Step 2 onward, print a short footer listing only options that are actionable at that point. `?` is always in the footer once anything is unlocked.
- If the user provides a Figma URL / PNG / file path up front, **infer aggressively** and skip the opening prompt.
- **Try WebFetch on any brand or product URL the user has already mentioned before asking them for image URLs directly.** Verify what you get: URL returns HTTP 200, and image content matches its label — download one sample and Read it before wiring the rest. Ask the user for URLs only after WebFetch fails or returns nothing usable. Fabricated URLs 404 silently through the LWC's image error handler (Failure Mode #8), so verify before you deploy. A PreToolUse hook (`hooks/verify-image-urls.sh`) enforces this at deploy time: it scans `*.cls` files in the selected source directory for `.jpg` / `.png` / `.gif` / `.webp` / `.svg` URLs and blocks `sf project deploy` if any return 4xx/5xx. Fix the URLs in-file, don't attempt to bypass the hook.
- **When a mechanism isn't working (image rendering, agent typing, Trusted URL config, targetConfigs binding, `agent_type` errors), retrieve a known-good reference from the same org and diff before inventing a fix.** `sf project retrieve start -m AiAuthoringBundle:<working-name>` — or the equivalent for `LightningComponentBundle` / `ApexClass` / `LightningTypeBundle`. Reference agents in the same org are the ground truth for what works there; cheaper than debugging blind.
- When an SFDX project is present, the state canvas at `<project>/LWC_BUILD_STATE.md` is the source of truth. In local preview mode, keep the same state in chat and do not create files.
- Convert relative dates in the user's messages to absolute dates when writing to the state canvas.
- **Always show progress.** Every question is labeled `Step N of ~M — <topic>` so the user knows where they are. The tilde is deliberate — count can shift ±2 based on answers.
- **After every substantive action**, emit a What / Why / Next block (see §C).

## When this skill applies

Trigger phrases:
- "Turn this Figma into an LWC that renders in chat"
- "I have a Figma design — how do I get it into Agentforce chat"
- "Guide me through building an in-chat LWC from Figma"
- "How do I render this Figma inside an agent chat bubble"

Does **not** apply if:
- The user has HTML but no Figma (this version is Figma-first — the archived multi-entry version at `~/Documents/claude/plugin homework/lwc-to-agentforce-chat-multi-entry/` covered HTML/existing-LWC/scan entries).
- The user only wants an LWC on a Lightning Record Page / App Page / Experience Builder page, not a chat bubble.
- The user is auditing an existing build without making changes.
- The user is authoring a Custom Lightning Type schema from scratch (use `generating-custom-lightning-type` first, then return here).
- The user has zero Salesforce context (start with `developing-agentforce`).

## Prerequisites

Start in **local preview mode**. Figma extraction, HTML preview generation, and the LWC transform require no Salesforce org, authentication, or SFDX project.

Only when the user asks to write deployable metadata or reaches the deploy phase, verify:

1. Agentforce / Enhanced Web Chat V2 is licensed and enabled in the org.
2. The user has admin access to the target org for later manual UI steps.
3. `sf config get target-org` returns the intended alias. If not, run `sf org list` and ask the user to choose.
4. `sfdx-project.json` exists at the project root. If not, offer to scaffold:
   ```json
   { "packageDirectories": [{"path":"force-app","default":true}],
     "name":"<dir-name>", "namespace":"",
     "sfdcLoginUrl":"https://login.salesforce.com", "sourceApiVersion":"66.0" }
   ```

## Load-bearing checkpoints

**Always require explicit YES before:**

- Writing any file under `force-app/`
- Writing the intermediary `<component-name>.preview.html` file (or any other file the skill emits for review)
- Running `sf project deploy` (any variant)
- Running `sf agent validate` / `sf agent publish` / `sf agent activate`
- Assigning a permset to any user (`sf org assign permset`)
- Overwriting `LWC_BUILD_STATE.md` when the user has hand-edited it since last turn
- Fetching a Figma URL via WebFetch — some Figma URLs contain tokens. Preview the URL + confirm YES before fetch.

At each checkpoint, print:

```
About to [action]. Preview:

[file path or command]
[preview content — first ~30 lines of file, or full command]

Reply YES to proceed, N to skip, or describe changes.
```

## Live State Canvas

When `sfdx-project.json` is present, write and maintain `<project-root>/LWC_BUILD_STATE.md` next to it. Create after the first substantive input and update after every answer and load-bearing checkpoint. **Echo the current canvas in chat after every update** so the user sees the state without opening the file. In local preview mode, render this structure in chat only; create no state file.

Exact structure:

```markdown
# LWC Build State: [Component Name or "Unnamed Build"]

*Maintained live by the lwc-to-agentforce-chat skill. Edits welcome — merged on next turn.*

## Context
**Flow:** Figma → HTML preview → LWC
**Figma source:** [URL or local path]
**Org:** [alias]
**Project root:** [absolute path]
**Client / Brand:** [name or (Not yet defined)]

## Component Identity
**LWC bundle name:** [lowerCamelCase, e.g. retailPersonalizedPicks]
**Apex DTO class:** [PascalCase, e.g. RetailProductPicksData]
**LightningType folder:** [PascalCase_underscore, e.g. Retail_ProductPicks]
**Purpose:** [one sentence]

## Brand
**Primary:** [hex] · **Secondary:** [hex] · **Accent:** [hex]
**Text:** [hex] · **Background:** [hex]
**Font:** [family] · **Border radius:** [px] · **Shadow:** [value]
**Logo:** [path or URL or (Not yet defined)]

## HTML Preview
**Path:** [<component>.preview.html or (in-chat only)]
**Approved:** [YES on YYYY-MM-DD | pending | edits requested: <list>]

## 5-Piece Contract
| Piece | Status | Notes |
|---|---|---|
| 1. Apex DTO | ✓/⚠/✗ | ... |
| 2. LightningType bundle | ✓/⚠/✗ | ... |
| 3. LWC bundle | ✓/⚠/✗ | ... |
| 4. Invocable Apex service | ✓/⚠/✗ | ... |
| 5. Agent Script (.agent) | ✓/⚠/✗ | ... |

## Decisions Made
- [YYYY-MM-DD] Figma source: ...
- [YYYY-MM-DD] Pattern: ...
- [YYYY-MM-DD] HTML preview approved.
- [YYYY-MM-DD] Naming prefix: ...

## Open Questions / Gaps
- ...

## Manual UI Steps Pending
- [ ] Switch ESD to Enhanced Messaging V2
- [ ] Set channel routing to None
- [ ] Add ECV2 connection in Agent Builder
- [ ] Trusted URLs (if external image hosts)
- [ ] Republish the ESD

## Deploy Status
- [ ] Apex (DTO first, then service)
- [ ] LightningType bundle + LWC bundle (together)
- [ ] Permission set
- [ ] CspTrustedSite (if external images)
- [ ] Agent bundle (validate → publish → activate)
- [ ] Permset assigned to bot user (`--on-behalf-of`)
```

**Merge rule:** if the user hand-edits the file between turns, read it before overwriting. Preserve their edits. If a conflict exists (skill wants to write X, file already has Y), ask.

## Standing options (progressive unlock — never dump all at once)

Nothing is actionable at Step 1, so no standing-options block appears then. Each standing option unlocks the first turn it becomes useful and stays unlocked for the rest of the session.

### Unlock rules

| Option | Unlocks when | Short-form footer |
|---|---|---|
| `C` — Show me what's been decided | After Step 2, once `LWC_BUILD_STATE.md` has been created. | `C=state` |
| `V` — Verify what's in the org vs. what's local | After the first successful `sf project deploy` — nothing to verify before that. | `V=verify org` |
| `E` — Export handoff documentation | When the build reaches its test/verify phase: after Step 10. | `E=export docs` |
| `R` — Details on a cited rule / failure mode | **Contextual only, never in the persistent footer.** Surface inline whenever the skill has just cited a specific `Failure Mode #N` or rule name the user might want to look up. | inline: `Type R to see details on Failure Mode #N` |

### Footer format from Step 2 onward

Short form only. Prefix with `?`.

```
? · C=state
```

As more options unlock, extend:

- Steps 2–10: `? · C=state`
- After first deploy: `? · C=state · V=verify org`
- After Step 10: `? · C=state · V=verify org · E=export docs`

### `?` handler — verbose descriptions on demand

When the user types `?`, print the plain-English descriptions **for only the currently unlocked options**. Never include locked options in the `?` output.

### Handling

- `C` → print the current `LWC_BUILD_STATE.md` verbatim in a fenced block.
- `R` → show the specific failure-mode entry from `references/failure-mode-crosswalk.md`, printed verbatim. Only respond to `R` if the previous turn cited a rule/failure mode.
- `V` → run `sf` queries (BotDefinition, MessagingChannel, LightningTypeBundle, PermissionSetAssignment for bot user) and diff against state canvas.
- `E` → invoke §B Phase 5 documentation export.
- `?` → print verbose descriptions of currently-unlocked options only.

## Compact update lines

After every user answer, print:
1. One acknowledgement line (`✓ <what changed>`)
2. If the change is substantive, a What / Why / Next block (see §C)
3. The next question, labeled `Step N of ~M — <topic>`
4. Currently-unlocked footer

Example (right after Step 2 unlocks `C`):

```
✓ Figma URL captured. State canvas created at LWC_BUILD_STATE.md.

Step 2 of ~11 — Extracting your Brand Summary now.

? · C=state
```

**Never:**
- Repeat the same summary twice
- Say "Great!" / "Perfect!" / "Absolutely" / "I'd love to help"
- Restate the plan the user just approved
- List everything you're about to do before doing it
- Omit the `Step N of ~M` label
- Skip the HTML preview at Step 3
- Print a standing option in the footer before it's unlocked

---

## Opening prompt (exact wording — send verbatim)

```
Step 1 of ~11 — Paste your Figma source.

Any one of:
  • Figma URL (share link or `figma.com/design/…` URL)
  • Local path to an exported PNG/JPG
  • Figma MCP node ID (format: file_key:node_id)

I'll extract the brand tokens, generate an intermediary HTML preview so you
can eyeball the design in a browser, and only after you approve it will I
transform it into the LWC bundle + the 5-piece contract.
```

No standing-options block on Step 1 — nothing is actionable yet.

If the user pastes source material with their first message, **skip the prompt** and go straight to Step 2 (extraction).

---

## Step 2 — Extract the Brand Summary

**Consults §B Phase 1.** Always hand off extraction to the `figma-extractor` subagent, including for the bundled PNG fixture. The subagent owns source routing and returns only the compact Brand Summary; the parent owns every later step.

Detection order (see `references/figma-extraction.md` for the full logic):

1. Check for `mcp__figma__*` tools in the current session. If present, use **Path A (Figma MCP)**.
2. If absent but a `figma` entry exists in the plugin's `.mcp.json` or `~/.claude/settings.json`, the MCP is registered but not authenticated. Tell the user: "Run `/mcp` to authenticate `plugin:lwc-to-agentforce-chat:figma`, then fully relaunch Claude Code — otherwise I'll fall back to WebFetch, which won't work on editor URLs." Continue with Path B if they proceed.
3. Otherwise, **Path B (WebFetch)** on a public Figma share URL.
   - **Load-bearing checkpoint:** preview the URL first + confirm YES.
   - **Editor-URL note:** `figma.com/design/…?m=dev` URLs are canvas SPAs — WebFetch returns only the login shell. Prefer Path A (MCP) or Path C (screenshot) for these.
4. If the input is a local PNG/JPG path → **Path C (image)**. Read the image visually.

After extraction, print the Brand Summary and ask:

```
Here's what I pulled from your Figma:

Brand Summary
─────────────────────────────
Primary:    #C41E3A (Retail Red)
Secondary:  #1A1A1A
Accent:     #FFB81C
Text:       #333333
Background: #FFFFFF
Font:       Inter
Border R:   8px
Shadow:     0 2px 8px rgba(0,0,0,0.08)
Pattern:    shopping_carousel (high confidence)
─────────────────────────────

Reply YES to move to Step 3 (HTML preview), or describe corrections.
```

Teaching after Step 2 (example):

```
✓ Step 2 of ~11 — Extracted brand tokens.

  What: Pulled primary #C41E3A, secondary #1A1A1A, accent #FFB81C, font Inter, radius 8px. Pattern inferred: shopping_carousel.
  Why:  These tokens become the LWC's CSS variables, and the pattern shape drives the HTML scaffolding I'll show you next. Extracting first means the HTML preview matches your design instead of a generic template.
  Next: Step 3 — I'll generate a full HTML preview of the card so you can review it in a browser before we transform to LWC.

? · C=state
```

---

## Step 3 — HTML preview (mandatory review checkpoint)

**This step is non-skippable.** No matter how confident the extraction was, the user reviews the intermediary HTML before any LWC bundle is generated.

Generate a single self-contained HTML file that renders exactly what the final LWC will render, styled with the Brand Summary tokens. The file must:

- Include all CSS inline in a `<style>` block (no external assets except Google Fonts).
- Use the primary/secondary/accent hex codes from the Brand Summary.
- Match the inferred pattern's structure (shopping_carousel → 3–4 horizontal card siblings; product_picks → vertical 3-card stack; etc.).
- Include realistic placeholder content (product names, prices, statuses) so the layout is legible — not `<h1>Card</h1>`.
- Be browser-openable directly (`open <path>` on macOS).

Filename convention: `<component-name>.preview.html` in the project root (or wherever the state canvas lives). If no SFDX project is present, write to the current working directory.

**Load-bearing checkpoint:** preview the first ~30 lines of the HTML, print the file path, and ask:

```
About to write <component-name>.preview.html. Preview:

<absolute-path>/<component-name>.preview.html
<first 30 lines>
...

Reply YES to write the preview file, N to skip and describe the design differently, or paste corrections.
```

After the file is written, print:

```
✓ HTML preview written to <absolute-path>/<component-name>.preview.html.

Open it in your browser (macOS: `open <path>`). Review the layout, colors, spacing, and copy.

Reply:
  YES — the HTML looks right, proceed to Step 4 (LWC transform).
  Edits: <describe what to change> — I'll regenerate and re-preview.
  N — abort and rethink the pattern.
```

**Do not proceed to Step 4 without a YES.** If the user requests edits, regenerate the file, re-write it (new checkpoint), and re-ask. Loop until YES.

Teaching after Step 3 (example):

```
✓ Step 3 of ~11 — HTML preview written and awaiting review.

  What: Rendered the extracted design as a self-contained shoppingCarousel.preview.html with 4 horizontal product cards using #C41E3A / #1A1A1A / #FFB81C.
  Why:  LWC constrains what you can see mid-build — no live preview, no browser-open. Reviewing the intermediary HTML here catches misread Figma tokens before we spend the transform + write cycle on LWC files.
  Next: Once you reply YES, Step 4 — I'll transform this HTML into an LWC bundle using the 8 transforms in references/html-to-lwc-transforms.md.

? · C=state
```

---

## Step 4 — Transform the approved HTML into an LWC bundle

**Consults §B Phase 2.** Runs only after Step 3 YES.

Apply the 8 transforms in `references/html-to-lwc-transforms.md` in order. Print a "will transform" preview showing before/after for the top 3 transforms that apply to the approved HTML. YES to proceed.

Emit the LWC bundle — `.html` template + `.css` sibling + `.js` shell with `@api value` getter/setter + `.js-meta.xml` with `lightning__AgentforceOutput` target + `<targetConfigs>` binding. Preview all four files. YES to write.

Teaching after Step 4:

```
✓ Step 4 of ~11 — HTML transformed to LWC bundle.

  What: Rewrote 3 button handlers (Transform #1), moved 8 inline styles to scoped .css (Transform #4), rewrote 2 conditional blocks to <template lwc:if> (Transform #6), added the @api value getter/setter and lightning__AgentforceOutput target.
  Why:  LWC uses shadow DOM and disallows inline expression eval in templates. These 8 transforms are the minimum set to get the approved HTML rendering cleanly inside an Agentforce chat bubble.
  Next: Step 5 — naming (prefix, LWC bundle, DTO class, LightningType folder).

? · C=state
```

Enforce these anti-patterns at transform time (full write-up of each in `references/failure-mode-crosswalk.md`):

- Single `connectedCallback` per file (never duplicate — Failure Mode #10)
- `@api value` getter/setter reactive pattern — not a plain prop read once (Failure Mode #9)
- `<targetConfigs>` block binding to the LightningType (Failure Mode #12)
- Image error handler hides broken images (`event.target.style.display = 'none'`) — Failure Mode #8

---

## Steps 5–10 — 5-Piece Contract

**Consults §B Phase 5.** One piece per step, one question at a time, YES per write.

5. **Naming.** Prefix (lowerCamelCase), LWC bundle name, Apex DTO class, LightningType folder. Use the naming table in §B Phase 5.
6. **Piece 1 preview (Apex DTO)** → YES → write. Cite Phase 2 Piece 1.
7. **Piece 2 preview (LightningType bundle: `schema.json`, `renderer.json`, `.lightningTypeBundle-meta.xml`)** → YES → write. Cite Phase 2 Piece 2.
8. **Piece 3 preview (LWC bundle)** — already generated at Step 4. Confirm final paths + write. Cite Phase 2 Piece 3.

   Teaching after Step 8:
   ```
   ✓ Step 8 of ~11 — LWC bundle written.

     What: Wrote retailShoppingCarousel/{.js,.html,.css,.js-meta.xml} with an @api value getter/setter that parses productsJSON from the DTO.
     Why:  The chat client updates value after mount; a plain @api prop reads once and never re-renders. This is Failure Mode #9 — "Card mounts, value populated, template renders blank."
     Next: Step 9 — Piece 4, the Invocable Apex service.

   Type R for details on Failure Mode #9.

   ? · C=state
   ```

9. **Piece 4 preview (Invocable Apex with Response DTO + narrative)** → YES → write. Cite Phase 2 Piece 4.
10. **Piece 5 preview (Agent Script `.agent` snippet with the two magic lines)** → YES → write. Cite Phase 2 Piece 5.

---

## Step 11 — Deploy checkpoint

Print the exact deploy sequence from §B Phase 5 ("Deploy sequence" below). The skill **never** runs `sf project deploy start` — the user runs it.

After Step 11, the `E=export docs` option unlocks.

---

## Reference sub-menu (invoked by `R`)

Only respond to `R` if the previous turn cited a specific rule or failure mode. Otherwise: "There's nothing cited yet; I'll surface `R` inline when I reference a specific Failure Mode."

When cited, print the specific entry from `references/failure-mode-crosswalk.md` verbatim — do not summarize. The reference values (retry counts, timing constants, SOQL queries to verify) are precise and cite-worthy.

For a full crosswalk of symptoms → failure mode numbers, see `references/failure-mode-crosswalk.md`.

---

# §B — Phase Playbooks

Each phase below is **reference material consulted by §A**, not a linear script.

---

## PHASE 1: Figma Extraction

**Consulted from §A when:** Step 2.

Three sub-paths, based on what's available:

- **Path A — Figma MCP** (if `mcp__figma__*` tools are in the session). Structured node access. Best fidelity.
- **Path B — WebFetch** on a public Figma URL. Extract from rendered CSS. Falls back gracefully — but does NOT work on `figma.com/design/…?m=dev` editor URLs.
- **Path C — Screenshot**. Read a local PNG/JPG visually.

**Full details:** `references/figma-extraction.md`. Includes MCP detection heuristics, WebFetch prompt shape, screenshot extraction rules, pattern-inference decision tree, and Brand Summary output format.

**Load-bearing checkpoint:** if fetching via WebFetch, preview the URL first + confirm YES.

**Output shape (Brand Summary):**

```
Brand Summary
─────────────────────────────
Primary:    #C41E3A (Retail Red)
Secondary:  #1A1A1A
Accent:     #FFB81C
Text:       #333333
Background: #FFFFFF
Font:       Inter
Border R:   8px
Shadow:     0 2px 8px rgba(0,0,0,0.08)
─────────────────────────────
```

See `references/figma-extraction.md` for the full detection logic, the source shape, and the Manual fallback path.

---

## PHASE 2: HTML → LWC Transform

**Consulted from §A when:** Step 4.

Applies 8 transformations in order:

1. Event handler binding — `onclick="fn()"` → `onclick={fn}`
2. Input event binding — `onchange="fn(this.value)"` → `onchange={handleChange}` + generated method
3. Image src binding — external URLs need `CspTrustedSite`
4. Inline styles → scoped `.css` sibling file
5. `<script>` tags → strip; logic into `.js` export class
6. Conditional rendering → `<template lwc:if>`
7. Loops → `<template for:each>` with `key`
8. Dynamic class strings → getter methods

**Full details:** `references/html-to-lwc-transforms.md`. Includes before/after examples per transform, gotchas, and cited failure modes.

Each transform emits its own What / Why / Next block when applied. The teaching layer is what turns a rote transform into a lesson.

See `references/html-to-lwc-transforms.md` for the full LWC bundle contract ("The receiving wrapper" section), plus a11y basics, Jest test scaffolding, and wire-adapter notes.

---

## PHASE 5: Shared 5-Piece Contract

**Consulted from §A when:** Steps 6–10.

A card only renders inside an Agentforce chat bubble if all five pieces below exist and the two required pairings match exactly. Each piece is previewed and written one step at a time (Steps 6–10); this section is the concrete template for each. Names below use `Retail_ShoppingCarousel` / `retailShoppingCarousel` as the running example — swap in whatever the user named their bundle at Step 5.

### Piece 1 — Apex DTO

Global class, `@JsonAccess` open in both directions, one `@AuraEnabled` field per value the LWC needs, a no-arg constructor plus a convenience constructor:

```apex
@JsonAccess(serializable='always' deserializable='always')
global class RetailShoppingCarouselData {
    @AuraEnabled
    global String productsJSON;

    global RetailShoppingCarouselData() {}

    global RetailShoppingCarouselData(String productsJSON) {
        this.productsJSON = productsJSON;
    }
}
```

### Piece 2 — LightningType bundle

Three files under `force-app/main/default/lightningTypes/<Folder>/`. `schema.json` binds field-by-field to the DTO with a `c__` prefix; `renderer.json` binds to the LWC; the `-meta.xml` wraps both.

`schema.json`:
```json
{
  "type": "object",
  "properties": {
    "c__productsJSON": {
      "type": "string",
      "title": "Products JSON"
    }
  }
}
```

`renderer.json`:
```json
{
  "type": "component",
  "component": {
    "name": "c/retailShoppingCarousel"
  }
}
```

`Retail_ShoppingCarousel.lightningTypeBundle-meta.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningTypeBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <masterLabel>Retail Shopping Carousel</masterLabel>
    <description>Renders a horizontal product carousel inside an Agentforce chat bubble.</description>
</LightningTypeBundle>
```

### Piece 3 — LWC bundle

`.js` with an `@api value` getter/setter (never a plain `@api` property — Failure Mode #9), `.html`, `.css`, and a `.js-meta.xml` with the `lightning__AgentforceOutput` target and a `<targetConfigs>` binding (Failure Mode #12). This bundle was already generated at Step 4 from the approved HTML. The full four-file shape, including the anti-patterns to avoid, is in `references/html-to-lwc-transforms.md` under "The receiving wrapper" and the end-to-end example.

### Piece 4 — Invocable Apex

`@InvocableMethod` returning both a displayable DTO output and a plain-text narrative for the LLM to speak:

```apex
public with sharing class RetailShoppingCarouselService {
    public class Request {
        @InvocableVariable(required=true)
        public String category;
    }

    public class Response {
        @InvocableVariable
        public RetailShoppingCarouselData carousel;

        @InvocableVariable
        public String narrative;
    }

    @InvocableMethod(label='Get Shopping Carousel' description='Returns a displayable product carousel plus a narrative for the LLM.')
    public static List<Response> getCarousel(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request req : requests) {
            List<Product2> products = [
                SELECT Id, Name, ProductCode
                FROM Product2
                WHERE Family = :req.category
                LIMIT 4
            ];
            Response res = new Response();
            res.carousel = new RetailShoppingCarouselData(JSON.serialize(products));
            res.narrative = 'Here are ' + products.size() + ' picks in ' + req.category + '.';
            responses.add(res);
        }
        return responses;
    }
}
```

### Piece 5 — Agent Script `.agent`

The action needs exactly two magic lines on its displayable output — `is_displayable: True` and `complex_data_type_name: "c__<LightningTypeFolder>"`. Without both, the chat surface prints raw text or JSON instead of mounting the card (Failure Mode #7):

```yaml
topic shopping_topic:
  label: "Shopping"
  description: "Shows a branded product carousel for a category."
  reasoning:
    instructions: ->
      | When the user asks to see products in a category, call
      | get_shopping_carousel with that category and let the narrative
      | introduce the carousel.
    actions:
      get_shopping_carousel:
        invocable: RetailShoppingCarouselService
        inputs:
          category: String
        outputs:
          carousel:
            type: String
            is_displayable: True
            complex_data_type_name: "c__Retail_ShoppingCarousel"
          narrative:
            type: String
```

### Two required pairings — must match exactly

- DTO field name ↔ LWC reads. DTO declares `@AuraEnabled global String productsJSON;` → LWC reads `this.value.productsJSON`.
- Apex `Response.<field>` ↔ `.agent outputs.<key>`. `Response.carousel` ↔ `outputs.carousel`.

### Naming conventions

| Layer | Example | Style |
|---|---|---|
| LightningType folder | `Retail_ShoppingCarousel` | PascalCase + underscore |
| LWC bundle | `retailShoppingCarousel` | lowerCamelCase |
| Apex DTO class | `RetailShoppingCarouselData` | PascalCase |

### Deploy sequence (Step 11)

The skill never runs `sf project deploy start` itself. It prints this sequence and the user runs it, in this order — deploy order matters, because the LightningType and LWC reference each other, and the agent bundle can't validate against pieces that aren't deployed yet:

```bash
# 1. Apex — DTO first, then the Invocable service
sf project deploy start --source-dir force-app/main/default/classes/RetailShoppingCarouselData.cls --target-org <alias> --ignore-conflicts
sf project deploy start --source-dir force-app/main/default/classes/RetailShoppingCarouselService.cls --target-org <alias> --ignore-conflicts

# 2. LightningType bundle + LWC bundle — deploy together
sf project deploy start \
  --source-dir force-app/main/default/lightningTypes/Retail_ShoppingCarousel \
  --source-dir force-app/main/default/lwc/retailShoppingCarousel \
  --target-org <alias> --ignore-conflicts

# 3. Permission set (Apex class access + LightningType access)
sf project deploy start --source-dir force-app/main/default/permissionsets/<PermSetName>.permissionset-meta.xml --target-org <alias> --ignore-conflicts

# 4. CspTrustedSite — only if the card loads images from an external host
sf project deploy start --source-dir force-app/main/default/cspTrustedSites --target-org <alias> --ignore-conflicts

# 5. Agent bundle — validate, publish, activate, in that order
sf project deploy start --source-dir force-app/main/default/aiAuthoringBundles/<AgentName> --target-org <alias> --ignore-conflicts
sf agent publish authoring-bundle --json --api-name <AgentName> --target-org <alias>
sf agent activate --api-name <AgentName> --target-org <alias>

# 6. Assign the permission set to the bot user, not the CLI/admin user (Failure Mode #13)
sf org assign permset --name <PermSetName> --target-org <alias> --on-behalf-of <BotUserUsername>

# 7. Verify
sf data query --query "SELECT Id, DeveloperName FROM BotDefinition WHERE DeveloperName = '<AgentName>'" --target-org <alias>
```

Assigning the permset to the wrong user is the single most common late-stage failure: the build looks complete, deploys clean, and then the agent throws `insufficient access rights on cross-reference id` the first time it tries to run the action.

**Documentation export (`E=export docs`):** writes three files to the project root —
- `BUILD_PROCESS.md` — the decisions made at each step (naming, pattern, brand tokens), every file written, every command the user ran, and any Debug Log entries.
- A Mermaid sequence diagram — Figma extraction → HTML preview approval → LWC transform → 5-piece contract writes → deploy → chat render.
- A deployment runbook — prerequisites checklist, the manual UI steps in order, the automated deploy sequence above, and rollback steps (deactivate the agent, remove the permset assignment, retract the LightningType).

---

# §C — Reference

## The What / Why / Next teaching-block template

Every substantive action produces this shape:

```
✓ Step <N> of ~<M> — <what just happened, past tense, one line>.

  What: <one sentence, past tense, concrete>.
  Why:  <one sentence, present tense, grounded in an LWC constraint or a v1 skill failure mode>.
  Next: <one sentence, future tense, tees up what's coming>.

? · <footer of currently unlocked options>
```

**Rules:**
- Progress label uses `~` because M can drift ±2.
- What is past tense, one line, no more.
- Why is one sentence, cites a failure mode by number when relevant (`Failure Mode #N` — full write-up in `references/failure-mode-crosswalk.md`).
- Next tees up the next step by number and topic.
- Footer is progressive-unlock.

**When to emit** (see `references/teaching-blocks.md` for the full list):
- Every time the skill writes a file, extracts a design token, generates an HTML preview, applies an HTML→LWC transform, names an identifier, reaches a load-bearing checkpoint, applies a failure-mode-preventing patch.

**When NOT to emit:**
- After a user question (progress label + question is enough).
- When restating state at user request via `C=state`.

### Three canonical examples

**Example 1 — Figma extraction complete**:
```
✓ Step 2 of ~11 — Extracted brand tokens from Figma.

  What: Pulled primary #C41E3A, secondary #1A1A1A, accent #FFB81C, font Inter, radius 8px.
  Why:  These tokens become the LWC's CSS variables, so the HTML preview and final card match your brand instead of rendering generic gray/white.
  Next: Step 3 — I'll generate an HTML preview of the card so you can review it in a browser.

? · C=state
```

**Example 2 — HTML preview written**:
```
✓ Step 3 of ~11 — HTML preview written and awaiting review.

  What: Rendered the extracted design as shoppingCarousel.preview.html with 4 horizontal cards using your brand hex codes.
  Why:  LWC doesn't offer a mid-build browser preview. Reviewing the intermediary HTML here catches misread Figma tokens before the transform + write cycle.
  Next: Once you reply YES, Step 4 — I'll transform this HTML into an LWC bundle.

? · C=state
```

**Example 3 — LWC bundle written**:
```
✓ Step 8 of ~11 — LWC bundle written.

  What: Wrote retailShoppingCarousel/{.js,.html,.css,.js-meta.xml} with an @api value getter/setter that parses productsJSON from the DTO.
  Why:  The chat client updates value after mount; a plain @api prop reads once and never re-renders. Failure Mode #9 (see references/failure-mode-crosswalk.md).
  Next: Step 9 — Piece 4, the Invocable Apex service.

Type R for details on Failure Mode #9.

? · C=state
```

## Progress-label rules

Every question gets `Step N of ~M — <topic>`. The tilde is deliberate — count can shift ±2 based on answers.

**Step budget:** ~11 steps end-to-end. Range: 9–13.

- Step 1: source
- Step 2: extract Brand Summary
- Step 3: HTML preview + review (may loop on edits)
- Step 4: transform to LWC bundle
- Step 5: naming
- Steps 6–10: 5-piece contract
- Step 11: deploy checkpoint

**When to update M mid-flow:**
- ±2 → keep the tilde
- ±3+ → print an explicit "Step count updated" line

**Step 3 loop:** if the user asks for edits, do NOT increment the step count. The step stays at 3 until the HTML is approved.

Full rules: `references/progress-labels.md`.

## Failure-mode crosswalk

This skill tracks 17 numbered failure modes plus a bonus entry. It cites them by number in teaching blocks and lets the user type `R` for the details.

**Failure Modes proactively checked at Step 4 (LWC transform):** #8 (image host → CspTrustedSite), #9 (@api value setter), #10 (single connectedCallback), #12 (targetConfigs).

Full crosswalk (all 17 + bonus, with symptom-to-diagnosis mapping): `references/failure-mode-crosswalk.md`.

**The `R=details` handler:** when a Failure Mode has been cited in the last turn, `R` prints the corresponding section of `references/failure-mode-crosswalk.md` verbatim. If nothing has been cited: "Nothing cited yet — I'll surface R inline when I reference a specific Failure Mode."

---

## Debug Log format

When the build hits an unexpected issue that isn't already documented in `references/failure-mode-crosswalk.md`, log it in the state canvas under a `## Debug Log` section. Format each entry:

```markdown
### DL-<N> — <one-line title>
**Date:** YYYY-MM-DD
**Step:** <N of ~M>
**Symptom:** <what the user or skill observed>
**Hypothesis(es):** <what we thought was wrong>
**Actual cause:** <what it turned out to be>
**Fix:** <what resolved it>
**Time cost:** <minutes>
```

Append-only. Never edit past entries — add a new entry with "Correction" in the title if the analysis was wrong.

---

## Final Checklist (invoked by `E=export docs`)

Before considering the build "done", verify all boxes:

**Setup**
- [ ] `sfdx-project.json` present
- [ ] `sf config get target-org` returns the intended alias
- [ ] Figma source captured and state canvas populated

**HTML preview**
- [ ] `<component>.preview.html` written
- [ ] User approved the preview (YES logged in state canvas)

**5-Piece Contract**
- [ ] Piece 1 (Apex DTO) written
- [ ] Piece 2 (LightningType bundle) written
- [ ] Piece 3 (LWC bundle) written with `@api value` getter/setter
- [ ] Piece 4 (Invocable Apex) written with displayable DTO + narrative
- [ ] Piece 5 (Agent Script action) written with `is_displayable: True` + `complex_data_type_name`

**Deploy**
- [ ] Apex deployed (DTO first, then service)
- [ ] LightningType + LWC deployed together
- [ ] Permission set deployed
- [ ] CspTrustedSite deployed (if external images)
- [ ] Agent bundle validated, published, activated
- [ ] Permset assigned to bot user via `--on-behalf-of`

**Manual**
- [ ] Enhanced Messaging V2 switched on the ESD
- [ ] Channel routing set to None
- [ ] ECV2 connection added in Agent Builder
- [ ] Trusted URLs added (if external images)
- [ ] ESD republished

**Verify**
- [ ] Test prompt triggers the action
- [ ] Card renders inside chat bubble (not raw JSON)
- [ ] Images load correctly
- [ ] No console errors in iframe context

**Documentation**
- [ ] `BUILD_PROCESS.md` exported
- [ ] `LWC_BUILD_STATE.md` final version saved
- [ ] Any DL entries reviewed

---

*End of SKILL.md. For deep-dive references, see `references/`. For examples, see `assets/examples/`.*
