---
name: lwc-to-agentforce-chat
description: >
  Turn what you have — a Figma design, an HTML prototype, an existing LWC, or
  just a folder — into a working Lightning Web Component that renders inside an
  Agentforce chat bubble. Guides and teaches at every step: what's happening,
  why it matters, and where you are in the flow.

  TRIGGER when: user has a Figma URL / Figma export / HTML file / existing LWC
  and wants it rendered inside Agentforce chat; user asks "how do I get this
  design into a chat card"; user says "I don't know where to start, help me
  figure out what I have"; user asks for a step-by-step guided build with
  progress tracking; user wants an LWC in an agent response bubble.

  DO NOT TRIGGER when: user wants an LWC on an Experience Builder page (use
  experience-cloud-site-builder Path A); user is auditing an existing build
  (use experience-cloud-site-builder Path C); user is authoring the Custom
  Lightning Type schema from scratch (use generating-custom-lightning-type
  first, then return here); user has zero Salesforce context (start with
  developing-agentforce for agent-first work).
license: MIT
experimental: true
metadata:
  version: "0.2.0"
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

**REQUIRED:** Use `experience-cloud-site-builder` for the 5-piece contract details, brand extraction (Phase 1.2), deploy sequence (Phase 8), manual UI steps (Phase 9), and the 17 failure modes (§C).

**REQUIRED:** Use `building-agentforce-clt-widget` for entry-point 3 (existing LWC) — its state detection algorithm and Branch B retrofit.

**RECOMMENDED:** Use `generating-lwc-components` for general LWC best practices (a11y, Jest, wire adapters).

**RECOMMENDED:** Use `applying-slds` for SLDS blueprints and styling hooks when the HTML source lacks them.

---

# lwc-to-agentforce-chat — Guided LWC-into-Chat Walkthrough

This skill is a **step-by-step guide with a teaching layer**. It has three sections:

- **§A Guided Flow** — the walkthrough. Start here. Always.
- **§B Phase Playbooks** — reference material each §A path consults, not a linear script.
- **§C Reference** — the What/Why/Next teaching-block template, progress-label rules, failure-mode crosswalk.

If you are Claude and you have opened this skill, do NOT dump §B or §C at the user. Follow §A. Cite §B / §C by phase/section number when needed.

The skill's core promise is **guiding + teaching**. Every substantive action produces a three-line What / Why / Next block (see §C or `references/teaching-blocks.md`). Reader learns without asking.

---

# §A — Guided Flow

## Ground rules (always in force)

- Keep commentary short: **1–3 sentences between menus**. No hype, no filler, no "Great question!" / "Perfect!" / "Absolutely" / "I'd love to help."
- Ask **exactly one question at a time** unless summarizing.
- Numbered menus in fenced code blocks. **Numeric replies map to the last menu shown.** Invalid number → re-show the same menu.
- **Never write files under `force-app/` or run deploys without explicit YES.** Preview → confirm → write.
- **Standing options unlock progressively** (see "Standing options" below). The opening menu shows *only* the 4 entry points — no `C/S/R/V/E` block. From Step 2 onward, print a short footer listing only the options that are actionable at that point. `?` is always in the footer once anything is unlocked.
- If the user provides source material (URL, file, project path), **infer aggressively before asking**. Prefer `(inferred)` values over follow-ups.
- The state canvas at `<project>/LWC_BUILD_STATE.md` is the source of truth. Update after every substantive answer.
- Convert relative dates in the user's messages to absolute dates when writing to the state canvas.
- **Always show progress.** Every question is labeled `Step N of ~M — <topic>` so the user knows where they are. The tilde is deliberate — count can shift ±2 based on answers.
- **After every substantive action**, emit a What / Why / Next block (see §C).

## When this skill applies

Trigger phrases:
- "Turn this Figma into an LWC that renders in chat"
- "I have an HTML prototype — how do I get it into Agentforce chat"
- "I have an LWC — wire it into the chat"
- "I don't know where to start — help me figure out what I have"
- "How do I render this design inside an agent chat bubble"
- "Guide me through building an in-chat LWC"

Does **not** apply if:
- The user only wants an LWC on a Lightning Record Page / App Page / Experience Builder page (use `experience-cloud-site-builder` Path A).
- The user is auditing an existing build without changes (use `experience-cloud-site-builder` Path C).
- The user is authoring a Custom Lightning Type schema from scratch (use `generating-custom-lightning-type` first, then return here).
- The user has zero Salesforce context (start with `developing-agentforce`).

## Prerequisites

Verify before starting. If any are missing, stop and tell the user before opening a menu.

1. Agentforce licensed and enabled in the org (Agentforce Employee agent type available).
2. Admin access to the target org (a few manual UI clicks required later — Trusted URLs mainly).
3. **Org selection.** Before Step 1, run `sf org list --all` to see authenticated orgs and ask:

   ```
   Org selection — which org should I deploy to?

     1) Use an existing authenticated org (I'll list what I found)
     2) Log into a new org

   Reply 1 or 2.
   ```

   - If **1**: print the `sf org list` results. Ask which alias. If none authenticated, force path 2.
   - If **2**: ask sandbox vs production, then hand the user the login command (they run it themselves; the CLI opens a browser):

     ```
     Is this a sandbox or a production org?

       1) Sandbox (test.salesforce.com)
       2) Production or Developer Edition (login.salesforce.com)
       3) Custom My Domain URL (paste it)
     ```

     Then:

     ```
     Type this yourself — the CLI will open a browser for you to log in:
       sf org login web --alias <your-alias> --instance-url <chosen-url>
     ```

     After they confirm success, `sf config set target-org <alias>` sets the default.

4. `sfdx-project.json` exists at the project root. **Do not announce or comment on a missing `sfdx-project.json` at Step 1 — it isn't relevant until files are about to be written.** Check silently. Only the first time you're about to write under `force-app/` (a load-bearing checkpoint), if it's missing, offer to scaffold it as part of that preview:
   ```json
   { "packageDirectories": [{"path":"force-app","default":true}],
     "name":"<dir-name>", "namespace":"",
     "sfdcLoginUrl":"https://login.salesforce.com", "sourceApiVersion":"66.0" }
   ```

## Testing surface — default to Agent Builder Preview

Preview (Setup → Agents → Open in Builder → Preview) is the default testing path. It is more reliable than ECV2 for iteration:

- No ESD / Enhanced Web Chat V2 wiring needed.
- No channel routing.
- Runs as the previewing user, not a service user.
- Immediate feedback loop after every deploy.

ECV2 / customer-facing chat is out-of-scope unless the user explicitly asks for it. Piece 5 (Agent Script) defaults to `agent_type: "AgentforceEmployeeAgent"` so Preview works.

**Gotcha — `agent_type` is immutable after v1 publish.** If a service agent (default) is published first, you cannot change to Employee later; you must republish under a fresh bundle API name. Full details: `references/preview-testing.md`.

## Load-bearing checkpoints

**Always require explicit YES before:**

- Writing any file under `force-app/`
- Running `sf project deploy` (any variant)
- Running `sf agent validate` / `sf agent publish` / `sf agent activate`
- Assigning a permset to any user (`sf org assign permset`)
- Overwriting `LWC_BUILD_STATE.md` when the user has hand-edited it since last turn
- Fetching a Figma URL via WebFetch — some Figma URLs contain tokens. Preview the URL + confirm YES before fetch.

**Always verify before deploying Piece 4:**

- **Every image URL in the mock Apex data must return HTTP 200.** If any URL 404s, the LWC image error handler (Failure Mode #8) hides the img element and the card renders with blank slots. Loop each URL with `curl -o /dev/null -s -w "%{http_code}"` before deploy. If any fail, stop and ask the user for working URLs — do not deploy placeholders that 404.
- **Watch for redirect chains.** CSP validates the final URL after any 302, so `picsum.photos` → `fastly.picsum.photos` needs both hosts trusted, or pick a host that doesn't redirect (`images.unsplash.com`, direct `assets.wsimgs.com` paths).
- **View one sample.** Download a sample URL and Read it to confirm the image content actually matches the product slot before deploying. Text saying "cookware" plus a photo of skincare is a bad demo.

Full playbook: `references/preview-testing.md`.

At each checkpoint, print:

```
About to [action]. Preview:

[file path or command]
[preview content — first ~30 lines of file, or full command]

Reply YES to proceed, N to skip, or describe changes.
```

## Live State Canvas

Write and maintain `<project-root>/LWC_BUILD_STATE.md` — next to `sfdx-project.json`. Create after the first substantive input. Update after every answer + at every load-bearing checkpoint. **Echo the current canvas in chat after every update** so the user sees the state without opening the file.

Exact structure:

```markdown
# LWC Build State: [Component Name or "Unnamed Build"]

*Maintained live by the lwc-to-agentforce-chat skill. Edits welcome — merged on next turn.*

## Context
**Entry point:** [Figma | HTML | Existing LWC | Scan-then-funnel]
**Org:** [alias]
**Project root:** [absolute path]
**Client / Brand:** [name or (Not yet defined)]

## Component Identity
**LWC bundle name:** [lowerCamelCase, e.g. wsifdePersonalizedPicks]
**Apex DTO class:** [PascalCase, e.g. WsifdeProductPicksData]
**LightningType folder:** [PascalCase_underscore, e.g. Wsifde_ProductPicks]
**Purpose:** [one sentence]

## Agent Identity
**Reuse existing or create new:** [Existing | New] (asked; never invented)
**Agent bundle API name:** [PascalCase, e.g. ChatCarouselDemo]
**Agent label:** [human-readable, e.g. "Chat Carousel Demo"]
**Agent type:** AgentforceEmployeeAgent (default — Preview-testable)
**Preview user:** [CLI's authenticated admin user, e.g. shing.diorio@example.com]
**Test prompt:** [one canonical trigger phrase the user will type into Preview, e.g. "show me the best cookware under $100"]

## Brand
**Primary:** [hex] · **Secondary:** [hex] · **Accent:** [hex]
**Text:** [hex] · **Background:** [hex]
**Font:** [family] · **Border radius:** [px] · **Shadow:** [value]
**Logo:** [path or URL or (Not yet defined)]

## 5-Piece Contract
| Piece | Status | Notes |
|---|---|---|
| 1. Apex DTO | ✓/⚠/✗ | ... |
| 2. LightningType bundle | ✓/⚠/✗ | ... |
| 3. LWC bundle | ✓/⚠/✗ | ... |
| 4. Invocable Apex service | ✓/⚠/✗ | ... |
| 5. Agent Script (.agent) | ✓/⚠/✗ | ... |

## Decisions Made
- [YYYY-MM-DD] Entry point: ...
- [YYYY-MM-DD] Naming prefix: ...

## Open Questions / Gaps
- ...

## Image URLs (verified before deploy)
| Slot | URL | HTTP code | Product |
|---|---|---|---|
| 1 | https://... | 200 | ... |

## Trusted URL Entries
| API Name | URL | Directives | Status |
|---|---|---|---|
| assets_wsimgs_com | assets.wsimgs.com | img-src | Added |

## Manual UI Steps Pending (Preview testing path)
- [ ] Add Trusted URL(s) for image host(s) — Setup → Trusted URLs → New (see fields in `references/preview-testing.md`)
- [ ] Verify in Preview: Setup → Agents → [Agent Label] → Open in Builder → Preview → paste the test prompt

## Deploy Status
- [ ] Apex (DTO first, then service)
- [ ] LightningType bundle + LWC bundle (together)
- [ ] Permission set
- [ ] Every image URL in Piece 4 verified 200
- [ ] Agent bundle validated, published, activated (Employee type)
- [ ] Permset assigned to CLI admin user (omit `--on-behalf-of` for Preview flow)
```

**Merge rule:** if the user hand-edits the file between turns, read it before overwriting. Preserve their edits. If a conflict exists (skill wants to write X, file already has Y), ask.

## Standing options (progressive unlock — never dump all at once)

**Never print the full 5-option block at Step 1.** Nothing is actionable there. Instead, each standing option unlocks the first turn it becomes useful, and stays unlocked for the rest of the session.

### Unlock rules

| Option | Unlocks when | Short-form footer |
|---|---|---|
| `C` — Show me what's been decided | After Step 2, once `LWC_BUILD_STATE.md` has been created. | `C=state` |
| `S` — Switch between entry points | After Step 2, once a path is picked (only meaningful once there's something to switch from). | `S=switch path` |
| `V` — Verify what's in the org vs. what's local | After the first successful `sf project deploy` — nothing to verify before that. | `V=verify org` |
| `E` — Export handoff documentation | When the build reaches its test/verify phase: Entry 1/2 step ≥ 8, Entry 3 step ≥ 6, Entry 4 after funnel completes 3+ steps. | `E=export docs` |
| `R` — Details on a cited rule / failure mode | **Contextual only, never in the persistent footer.** Surface inline whenever the skill has just cited a specific `Failure Mode #N` or rule name the user might want to look up. | inline: `Type R to see details on Failure Mode #N` |

### Footer format from Step 2 onward

Short form only. Prefix with `?`.

```
? · C=state · S=switch path
```

As more options unlock, extend:

- Step 2 (all entry points): `? · C=state · S=switch path`
- After first deploy: `? · C=state · S=switch path · V=verify org`
- Entering test phase: `? · C=state · S=switch path · V=verify org · E=export docs`

### `?` handler — verbose descriptions on demand

When the user types `?`, print the plain-English descriptions **for only the currently unlocked options**. Never include locked options in the `?` output.

### Handling

- `C` → print the current `LWC_BUILD_STATE.md` verbatim in a fenced block.
- `S` → confirm the switch (existing decisions may not apply), then re-run source inference for the new entry.
- `R` → show the specific §C failure-mode entry (delegates to `experience-cloud-site-builder` §C for the full content). Only respond to `R` if the previous turn cited a rule/failure mode.
- `V` → run `sf` queries (BotDefinition, MessagingChannel, LightningTypeBundle, PermissionSetAssignment for bot user) and diff against state canvas.
- `E` → invoke §B Phase 5 documentation export.
- `?` → print verbose descriptions of currently-unlocked options only.

## Compact update lines

After every user answer, print:
1. One acknowledgement line (`✓ <what changed>`)
2. If the change is substantive, a What / Why / Next block (see §C)
3. The next question, labeled `Step N of ~M — <topic>`
4. Currently-unlocked footer

Example (right after Step 2 unlocks `C` and `S`):

```
✓ Entry point: Figma. State canvas created at LWC_BUILD_STATE.md.

Step 2 of ~12 — Paste your Figma URL, or point at an exported PNG/JPG file path.

? · C=state · S=switch path
```

**Never:**
- Repeat the same summary twice
- Say "Great!" / "Perfect!" / "Absolutely" / "I'd love to help"
- Restate the plan the user just approved
- List everything you're about to do before doing it
- Omit the `Step N of ~M` label
- Print a standing option in the footer before it's unlocked

---

## Opening prompt (exact wording — send verbatim)

```
Step 1 of ~9-12 — What do you have to start from?

  1) A Figma design (URL, share link, or exported PNG)
     Path: Figma → LWC → chat. ~12 steps. Best for design handoff.
  2) An HTML/CSS prototype (a file or a snippet)
     Path: HTML → LWC → chat. ~11 steps. Best for design system components.
  3) An existing LWC (already in your force-app/)
     Path: LWC → chat wiring. ~9 steps. Best when the visual is done.
  4) Not sure — scan my folder and help me decide
     Path: I read your project, tell you what you have, then pick 1–3 for you.

Reply 1, 2, 3, or 4. Or paste a URL / file / project path and I'll infer.
```

No standing-options block on Step 1 — nothing is actionable yet.

If the user asks "which should I pick?" or seems unsure, ask this before repeating the menu:

```
One clarifying question — what's the most polished thing you have right now?

A) A visual design (Figma, screenshot, or a mocked-up image)  → Path 1 (Figma)
B) Markup and styles (HTML/CSS I can read)                     → Path 2 (HTML)
C) A working component in force-app/                           → Path 3 (Existing LWC)
D) Not sure — I want you to look and tell me                  → Path 4 (Scan)
```

If the user pastes source material directly (URL / file / path), **skip the menu** and go to **Source Inference** below.

## Source Inference (skip the menu if source is present)

Run this **before** asking any questions when source material is present.

1. **Read / probe the source.**
   - URL matching Figma pattern (figma.com/design/, figma.com/file/) → Entry 1
   - URL matching anything else that looks like a design tool → Entry 1 (offer to try)
   - Local file `.html`, `.htm` → Entry 2
   - Local file `.png`, `.jpg`, `.jpeg` → Entry 1 (screenshot path)
   - Local path pointing at `force-app/main/default/lwc/<name>/` → Entry 3
   - Local path pointing at a project root with `sfdx-project.json` → Entry 4 (scan)
   - Anything else → ask
2. **Populate the state canvas** with everything inferable.
3. **Emit a summary** in this exact shape:

```
Here's what I pulled from your source:
- Entry inferred: [Figma | HTML | Existing LWC | Scan]
- Existing artifacts: [comma-separated list of found LWCs / Apex / agents / lightning types, if any]
- Naming prefix: [detected or (Not yet defined)]
- Brand: [primary/secondary/accent hex + font, or (Not yet defined)]
- Gaps: [list]

How do you want to proceed?
1) Fast mode — I fill remaining gaps with best guesses, confirm at load-bearing steps
   Estimate: ~3–6 questions
2) Detailed mode — I ask one question per unresolved dimension
   Estimate: ~10–15 questions
Reply 1 or 2.
```

Mode recommendation:
- **Fast** when source is strong (existing project with metadata, or a well-branded URL) **and gaps ≤ 5**.
- **Detailed** when source is weak or user asks for precision.

---

## Entry point 1 — Figma → LWC (~12 steps)

**Consults §B Phase 1 and Phase 5.** One question at a time. Update state canvas after each. Emit a What / Why / Next block after every substantive action.

```
Entry 1: Figma → LWC — I'll extract your brand, infer the pattern, then walk the 5-piece contract.

Step 2 of ~12 — Paste your Figma URL, or point at an exported PNG/JPG file path.
```

Sequence (Step 1 was the surface pick):

2. **Figma source.** URL, screenshot path, or exported PNG path.
3. **Extract design tokens.** See Phase 1. If a Figma MCP server is configured (grep `~/.claude/settings.json` or `<project>/.mcp.json` for `figma`), use it. Otherwise WebFetch the public URL. If Screenshot, Read the image visually.
   - **Load-bearing checkpoint:** if fetching via WebFetch, preview the URL first + confirm YES.
4. **Infer visual pattern** from extracted structure. Match against 4 preset patterns:
   - ≥3 identical horizontal siblings with image + text + price → shopping carousel
   - Date grid + time-slot pills → appointment scheduler
   - Status timeline (dot-line-dot-line-dot) → order status card
   - Vertical curated 3-card stack with reasoning line → product picks
   - If none match: ask user to describe the pattern.
5. **Present Brand Summary** (see Phase 1 output shape). YES to proceed.

   Teaching after Step 5 (example):
   ```
   ✓ Step 5 of ~12 — Extracted brand tokens.

     What: Pulled primary #C41E3A, secondary #1A1A1A, accent #FFB81C, font Inter, radius 8px.
     Why:  These tokens become the LWC's CSS variables, so the card matches your brand instead of rendering generic gray/white.
     Next: Step 6 — I'll ask for a naming prefix, then generate the 5-piece contract.

   ? · C=state · S=switch path
   ```
6. **Naming.**
   - Component prefix (lowerCamelCase), LWC bundle name, Apex DTO class, LightningType folder. Cite `experience-cloud-site-builder` Phase 2 naming table.
   - **Agent identity — ask, don't invent:**
     ```
     Agent identity — before Piece 5:
       1) Create a new agent. What should the API name be? (PascalCase, no spaces)
       2) Reuse an existing agent (paste its API name — I'll retrieve it and add a subagent)
     ```
     Existing → `sf project retrieve start -m AiAuthoringBundle:<name> --target-org <alias>` first, then edit. New → capture the name for the state canvas.
   - **Test prompt — ask now, use later:** "What's a natural user prompt that should trigger this action?" (e.g. `show me the best cookware under $100`). Record in state canvas. The skill will echo this prompt back verbatim in the Preview verification step.
7. **Piece 1 preview (Apex DTO)** → YES → write. Cite Phase 2 Piece 1.
8. **Piece 2 preview (LightningType bundle: `schema.json`, `renderer.json`, `.lightningTypeBundle-meta.xml`)** → YES → write. Cite Phase 2 Piece 2.
9. **Piece 3 preview (LWC bundle: `.js` with `@api value` getter/setter, `.html`, `.css`, `.js-meta.xml`)** → YES → write. Cite Phase 2 Piece 3.

   Teaching after Step 9:
   ```
   ✓ Step 9 of ~12 — LWC bundle written.

     What: Wrote wsifdeShoppingCarousel.js with an @api value getter/setter that parses productsJSON from the DTO.
     Why:  The chat client updates value after mount; a plain @api prop reads once and never re-renders. This is Failure Mode #9 in experience-cloud-site-builder — "Card mounts, value populated, template renders blank."
     Next: Step 10 — Piece 4, the Invocable Apex service.

   Type R for details on Failure Mode #9.

   ? · C=state · S=switch path
   ```
10. **Piece 4 preview (Invocable Apex with Response DTO + narrative)** → YES → write. Cite Phase 2 Piece 4.
    - **Image URL verification (mandatory before deploy).** Loop `curl` over every image URL in the mock data. Any non-200 → stop and ask the user for real URLs. Download one sample and Read it to confirm the photo matches the product it labels (not a generic placeholder). Details: `references/preview-testing.md`.
    - **Trusted URL provisioning instructions.** After Piece 4 is written, print the exact Setup → Trusted URLs UI fields (API Name / URL / CSP Context = All / CSP Directives = img-src only / Active). Field-by-field, not prose.
11. **Piece 5 preview (Agent Script `.agent` snippet, Employee-typed by default)** → YES → write. Cite Phase 2 Piece 5. Includes `agent_type: "AgentforceEmployeeAgent"`, omits `variables:` and `default_agent_user:`.
12. **Deploy checkpoint.** Print the deploy sequence + Preview verification block (Setup path + the recorded test prompt verbatim). The skill never runs `sf project deploy start` — user runs it.

At Piece 3 (Step 9), enforce these anti-patterns from `experience-cloud-site-builder` §C Failure Modes:
- Single `connectedCallback` per file (never duplicate — Failure Mode #10)
- `@api value` getter/setter reactive pattern — not a plain prop read once (Failure Mode #9)
- `<targetConfigs>` block binding to the LightningType (Failure Mode #12)
- Image error handler hides broken images (`event.target.style.display = 'none'`) — Failure Mode #8

---

## Entry point 2 — HTML → LWC (~11 steps)

**Consults §B Phase 2 and Phase 5.** One question at a time. Update state canvas after each.

```
Entry 2: HTML → LWC — I'll transform your HTML into LWC template + JS + CSS, then wrap it in the 5-piece contract.

Step 2 of ~11 — Paste your HTML, or point at a file (.html, .htm, or a directory containing them).
```

Sequence:

2. **HTML source.** Paste or file path.
3. **Parse the HTML.** Read the file. Identify: root element, event handlers, inline styles, script tags, external resources. Print a summary of what was found (element count, handler count, image URLs, style approach).
4. **Transform to LWC template.** Apply the 8 transforms in `references/html-to-lwc-transforms.md`. Print a "will transform" preview showing before/after for the top 3 transforms that apply. YES to proceed.

   Teaching after Step 4:
   ```
   ✓ Step 4 of ~11 — HTML converted to LWC template.

     What: Rewrote 3 button handlers (Transform #1), moved 8 inline styles to a scoped .css (Transform #4), and rewrote 2 conditional blocks to <template lwc:if> (Transform #6).
     Why:  LWC uses shadow DOM — inline styles are allowed but harder to theme. Scoped CSS in the .css sibling file is the LWC convention. Handler bindings compile as method references, not eval strings.
     Next: Step 5 — I'll emit the four LWC bundle files (.html, .css, .js, .js-meta.xml).

   ? · C=state · S=switch path
   ```
5. **Emit LWC bundle** — `.html` template + `.css` sibling + `.js` shell with `@api value` getter/setter + `.js-meta.xml` with targets `lightning__AgentforceOutput` + `<targetConfigs>` binding. Preview all four files. YES to write.
6. **Naming** (same as Entry 1 Step 6 — includes agent identity ask + test prompt capture).
7. **Piece 1 preview (Apex DTO)** → YES → write. Cite Phase 2 Piece 1.
8. **Piece 2 preview (LightningType bundle)** → YES → write. Cite Phase 2 Piece 2.
9. **Piece 4 preview (Invocable Apex)** → YES → write. Cite Phase 2 Piece 4.
    - **Image URL verification (mandatory).** Same rules as Entry 1 Step 10 — every URL 200, one sample viewed. See `references/preview-testing.md`.
    - **Trusted URL provisioning instructions** — print exact fields.
10. **Piece 5 preview (Agent Script `.agent`, Employee-typed by default)** → YES → write. Cite Phase 2 Piece 5.
11. **Deploy checkpoint.** Same as Entry 1 Step 12 — print test prompt verbatim.

Note: Piece 3 (LWC bundle) is emitted at Step 5 as part of the transform, so Steps 7–10 cover Pieces 1, 2, 4, 5 in that order.

---

## Entry point 3 — Existing LWC → chat wiring (~9 steps)

**Consults §B Phase 3 and Phase 5.** Primarily delegates to `building-agentforce-clt-widget` (a sibling skill dedicated to this scenario). This entry orchestrates + teaches; clt-widget does the state-detection heavy lifting.

```
Entry 3: Existing LWC → chat wiring — I'll detect what pieces you have, then fill the gaps.

Step 2 of ~9 — Point at the LWC. Bundle path (force-app/main/default/lwc/<name>/) or component name (I'll find it).
```

Sequence:

2. **Point at the LWC.** Path or name.
3. **Delegate to `building-agentforce-clt-widget` Step 1 detection.** Print its 5-row state table:

   ```
   Detected pieces of the 5-piece contract:
   | Piece | Status | Path |
   |---|---|---|
   | 1. Apex DTO | ✓/⚠/✗ | ... |
   | 2. LightningType bundle | ✓/⚠/✗ | ... |
   | 3. LWC bundle | ✓/⚠/✗ | ... |
   | 4. Invocable Apex service | ✓/⚠/✗ | ... |
   | 5. Agent Script (.agent) | ✓/⚠/✗ | ... |
   ```

4. **Determine branch** (from clt-widget skill):
   - **A** — nothing exists → shortest path from zero (rare, funnels back to Entry 1 or 2)
   - **B** — LWC exists → retrofit (primary path)
   - **C** — partial pieces → fill gaps only

   Teaching after Step 4:
   ```
   ✓ Step 4 of ~9 — Detected Branch C (partial retrofit).

     What: You have Piece 1 (DTO) and Piece 3 (LWC). Missing: 2 (LightningType), 4 (Invocable), 5 (.agent action).
     Why:  The 5-piece contract needs all five. Without Piece 2, the chat client doesn't know which LWC to render for your DTO — it falls back to raw JSON (Failure Mode #7).
     Next: Step 5 — I'll add the three missing pieces, one at a time with previews.

   Type R for details on Failure Mode #7.

   ? · C=state · S=switch path
   ```

5. **Retrofit missing pieces** one at a time. YES per piece. Cite `building-agentforce-clt-widget` for each piece's contract, and cite `experience-cloud-site-builder` Phase 2 for the actual template.
6. **Verify `@api value` getter/setter** present in the LWC .js. If absent, patch it (with preview + YES).

   Teaching after Step 6:
   ```
   ✓ Step 6 of ~9 — Patched @api value into a reactive getter/setter.

     What: Replaced `@api value;` with a getter/setter pair that re-parses the incoming DTO's payload on every update.
     Why:  Your original LWC read value once at mount. Fine on an EB page, breaks in chat where the payload arrives after mount. This is Failure Mode #9.
     Next: Step 7 — I'll verify your .js-meta.xml has the lightning__AgentforceOutput target and a targetConfigs binding.

   ? · C=state · S=switch path
   ```

7. **Verify `.js-meta.xml`** has `lightning__AgentforceOutput` target and a `<targetConfigs>` block binding to the LightningType. Failure Mode #12 catches missing targetConfigs.
8. **Materialize any missing pieces** (DTO, LightningType, Invocable, Agent Script) not yet written in Step 5. If Piece 4 (Invocable) or Piece 5 (Agent Script) is being written here:
    - **Ask agent identity** (new API name or reuse existing — see `references/preview-testing.md` §3). Capture in state canvas.
    - **Capture test prompt** — one canonical trigger phrase the user will paste into Preview.
    - **Verify image URLs 200** before deploy (Piece 4 rule from Entry 1 Step 10).
    - Piece 5 defaults to `agent_type: "AgentforceEmployeeAgent"`.
9. **Deploy checkpoint.** Same as Entry 1 Step 12 — print test prompt verbatim.

---

## Entry point 4 — "I don't know what I have" (~7 steps + funnel)

**Consults §B Phase 0 (Pre-flight) and §B Phase 4 (Folder Scan).** No numbered menu — scan runs, recommendation emitted, then funnel to the picked entry point.

```
Entry 4: Scan my folder — I'll read your project and recommend an entry point.

Step 2 of ~7 — Confirm the project root. Reply with the absolute path, or "here" if I should use the current directory.
```

Sequence:

2. **Confirm project root.** `sf config get target-org` optional; the folder scan only needs a local path.
3. **Scan.** See `references/entry-point-detection.md` for the exact `find`/`grep` patterns. Detect:
   - Figma export files (`*.fig`, `.figma/`, PNG/JPG in `exports/`/`design/`/`mockups/`)
   - Standalone HTML files (at root or in `prototype/`, `demo/`, `mockups/`)
   - SFDX project structure (`sfdx-project.json`, `force-app/main/default/lwc/`, etc.)
   - Existing LWCs (bundles with `.js-meta.xml`)
   - Existing DTOs (Apex classes with `@JsonAccess(serializable='always')`)
   - Existing LightningTypes (`schema.json` files)
   - Existing Agent Script bundles (`.agent` files)
4. **Emit inventory** — human-readable list of what was found (see Phase 4 emit shape).
5. **Recommend an entry point** based on findings (priority table in `references/entry-point-detection.md`):
   - Existing LWC bundle → Entry 3 (retrofit)
   - HTML file present + no LWC → Entry 2
   - Figma-shaped assets + no LWC + no HTML → Entry 1
   - Nothing found → prompt user to describe input
6. **Ask the user to confirm the recommendation.** If they disagree, offer alternatives with rationale.

   Teaching after Step 6:
   ```
   ✓ Step 6 of ~7 — Recommended Entry 3 based on scan.

     What: Found force-app/main/default/lwc/wsifdePersonalizedPicks/ with a .js-meta.xml. Also found the matching DTO WsifdeProductPicksData.cls.
     Why:  When an LWC bundle already exists, retrofit (Entry 3) is always faster than rebuilding from Figma or HTML. You already have Pieces 1 and 3 — we just need 2, 4, 5.
     Next: Step 7 — Funnel to Entry 3, Step 3 (state detection). Step count reset — you're now in Entry 3, Step 3 of ~9.

   ? · C=state · S=switch path
   ```

7. **Funnel** to the picked entry point at its Step 2 (or Step 3 for Entry 3, since state detection is Step 3 there).

Note: When funneling, print an explicit "Step count reset" line and the new `Step N of ~M` label.

---

## Reference sub-menu (invoked by `R`)

Only respond to `R` if the previous turn cited a specific rule or failure mode. Otherwise: "There's nothing cited yet; I'll surface `R` inline when I reference a specific Failure Mode."

When cited, print the specific §C entry from `experience-cloud-site-builder` verbatim — do not summarize. The reference values (retry counts, timing constants, SOQL queries to verify) are precise and cite-worthy.

For a full crosswalk of symptoms → failure mode numbers, see `references/failure-mode-crosswalk.md`.

---

# §B — Phase Playbooks

Each phase below is **reference material consulted by §A**, not a linear script. §A determines which phases apply, in what order, and how much to invoke.

---

## PHASE 0: Pre-flight Inventory

**Consulted from §A when:** Entry 4 (Scan) always. Entry 3 (Existing LWC) at Step 3. Entry 1 / 2 skip this phase (they start from source material, not org state).

**Do this FIRST when relevant.** Before building anything, look for existing artifacts. Reuse aggressively.

```bash
# Which org?
sf config get target-org

# List existing agents
sf data query -q "SELECT Id, MasterLabel, DeveloperName, Type FROM BotDefinition" -o <alias>

# List potentially-relevant Apex classes
sf data query -q "SELECT Name FROM ApexClass WHERE Name LIKE '<customer-prefix>%'" -o <alias>

# List existing Messaging Channels
sf data query --query "SELECT Id, DeveloperName, IsActive, RoutingType FROM MessagingChannel" -o <alias>

# Retrieve anything relevant into local source
sf project retrieve start \
  -m "ApexClass:<DTOClass>" \
  -m "ApexClass:<ServiceClass>" \
  -m "LightningTypeBundle" \
  -m "LightningComponentBundle:<lwcName>" \
  -m "Bot:<BotName>" \
  -m "AiAuthoringBundle:<BundleName>" \
  -o <alias>
```

If you find any of the pieces already exist, **read them and adapt** rather than rebuild.

Full details on which signals recommend which entry point: see `references/entry-point-detection.md`.

---

## PHASE 1: Figma Extraction

**Consulted from §A when:** Entry 1 Step 3.

Three sub-paths, based on what's available:

- **Path A — Figma MCP** (if configured). Structured node access. Best fidelity.
- **Path B — WebFetch** on a public Figma URL. Extract from rendered CSS. Falls back gracefully.
- **Path C — Screenshot**. Read a local PNG/JPG visually.

**Full details:** `references/figma-extraction.md`. Includes MCP detection heuristics, WebFetch prompt shape, screenshot extraction rules, pattern-inference decision tree, and Brand Summary output format.

**Load-bearing checkpoint:** if fetching via WebFetch, preview the URL first + confirm YES.

**Output shape (Brand Summary):**

```
Brand Summary
─────────────────────────────
Primary:    #C41E3A (WSI Red)
Secondary:  #1A1A1A
Accent:     #FFB81C
Text:       #333333
Background: #FFFFFF
Font:       Inter
Border R:   8px
Shadow:     0 2px 8px rgba(0,0,0,0.08)
─────────────────────────────
```

Cross-references: `experience-cloud-site-builder` Phase 1.2 for the source shape and Manual fallback.

---

## PHASE 2: HTML → LWC Transform

**Consulted from §A when:** Entry 2 Step 4.

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

Cross-references: `experience-cloud-site-builder` Phase 2 Piece 3 for the full LWC bundle contract; `generating-lwc-components` for a11y, Jest, wire adapters.

---

## PHASE 3: Existing LWC Retrofit

**Consulted from §A when:** Entry 3 always. Primarily delegates to `building-agentforce-clt-widget`.

That sibling skill owns:
- State detection algorithm (Step 1 there — the 5-row status table)
- Branch A/B/C decision rule
- Retrofit sequencing for missing pieces
- CLT (Custom Lightning Type) rendition specifics

This skill orchestrates and teaches; the sibling does the wiring.

**Key anti-patterns to catch at retrofit time** (all from `experience-cloud-site-builder` §C):

- LWC targets `lightning__RecordAction` or `lightningCommunity__Page` but NOT `lightning__AgentforceOutput` → patch the `.js-meta.xml`
- LWC has `@api value` as a plain prop, not getter/setter → patch to reactive setter (Failure Mode #9)
- LWC has multiple `connectedCallback` methods → consolidate (Failure Mode #10)
- LWC image handler falls back to a placeholder URL → change to hide broken images (Failure Mode #8)
- `.js-meta.xml` missing `<targetConfigs>` block → add it (Failure Mode #12)

---

## PHASE 4: Folder Scan

**Consulted from §A when:** Entry 4 always. Optional for Entries 1–3 at user request.

The scan reads the project folder and recommends an entry point based on what it finds. Full patterns (find commands, glob patterns, decision priority) in `references/entry-point-detection.md`.

**Emit shape** (verbatim template):

```
Scanning `<absolute-path>`...

Found:
  • sfdx-project.json (project root confirmed)
  • force-app/main/default/lwc/<name>/ — <N> LWC bundle(s)
  • force-app/main/default/classes/<DTO>.cls — <N> Apex DTO(s)
  • <LightningType status>
  • <Invocable Apex status>
  • <Agent Script bundle status>

Recommendation: **Entry <N> — <name>**
  <one-sentence rationale grounded in what was found>

Alternatives:
  • Entry <M> — if you want <rationale>
  • Entry <K> — if you want <rationale>

Reply <N> to proceed with the recommendation, or 1/2/3/4 for an alternative.
```

Cross-references: `building-agentforce-clt-widget` Step 1 — reuse its 5-row state table when relevant pieces are detected.

---

## PHASE 5: Shared 5-Piece Contract

**Consulted from §A when:** All entries at their piece-writing steps (Entry 1 Steps 7–11, Entry 2 Steps 7–10, Entry 3 Steps 5 and 8).

**This phase is a thin wrapper.** The 5-piece contract templates live in `experience-cloud-site-builder` Phase 2 — do not duplicate them here.

The five pieces:
1. **Apex DTO** — global class, `@JsonAccess(serializable='always' deserializable='always')`, `@AuraEnabled` field, two constructors. Details: `experience-cloud-site-builder` Phase 2 Piece 1.
2. **LightningType bundle** — `schema.json` binds to the DTO with `c__` prefix; `renderer.json` binds to the LWC; `.lightningTypeBundle-meta.xml` wraps them. Details: Phase 2 Piece 2.
3. **LWC bundle** — `.js` with `@api value` getter/setter, `.html`, `.css`, `.js-meta.xml` with `lightning__AgentforceOutput` target + `<targetConfigs>` binding. Details: Phase 2 Piece 3.
4. **Invocable Apex** — `@InvocableMethod` returning both a displayable DTO output AND a text narrative for the LLM. Details: Phase 2 Piece 4.
5. **Agent Script `.agent`** — action with the two magic lines: `is_displayable: True` + `complex_data_type_name: "c__<LightningTypeFolder>"`. Details: Phase 2 Piece 5.

   **Preview-testable defaults (this skill's convention):**
   - `agent_type: "AgentforceEmployeeAgent"` inside `config:` — required for Preview to run
   - No `variables:` block — Preview has no MessagingSession
   - No `default_agent_user:` — Employee agents run as the previewing user

   **Gotcha:** `agent_type` is immutable after v1 publish. If a service agent was published first, rename the bundle (folder + `developer_name` + `agent_label`) to a fresh API name and publish that as a new v1. Details: `references/preview-testing.md`.

   **Permset assignment for Preview:** assign to the CLI's admin user (`sf org assign permset -n <Name> --target-org <alias>` — omit `--on-behalf-of`). The service agent user does NOT run the agent in Preview.

**Two required pairings** — must match exactly:
- DTO field name ↔ LWC reads. DTO declares `@AuraEnabled global String productsJSON;` → LWC reads `this.value.productsJSON`.
- Apex `Response.<field>` ↔ `.agent outputs.<key>`. `Response.carousel` ↔ `outputs.carousel`.

**Naming conventions** (also in `experience-cloud-site-builder` Phase 2):
| Layer | Example | Style |
|---|---|---|
| LightningType folder | `Wsifde_ShoppingCarousel` | PascalCase + underscore |
| LWC bundle | `wsifdeShoppingCarousel` | lowerCamelCase |
| Apex DTO class | `WsifdeShoppingCarouselData` | PascalCase |
| Agent bundle API name | `WsifdeShoppingAssistant` | PascalCase (asked, never invented) |
| Trusted URL API name | `assets_wsimgs_com` | snake_case, hostname-derived |

**Documentation export (`E=export docs`):** invokes Phase 12 of `experience-cloud-site-builder` — generates `BUILD_PROCESS.md` + Mermaid sequence diagram + runbook in the project root.

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
- Why is one sentence, cites a failure mode by number when relevant (`Failure Mode #N in experience-cloud-site-builder`).
- Next tees up the next step by number and topic.
- Footer is progressive-unlock.

**When to emit** (see `references/teaching-blocks.md` for the full list):
- Every time the skill writes a file, extracts a design token, detects state, transforms HTML → LWC, names an identifier, reaches a load-bearing checkpoint, applies a failure-mode-preventing patch, or switches entry points.

**When NOT to emit:**
- After a user question (progress label + question is enough).
- After a menu.
- When restating state at user request via `C=state`.

### Three canonical examples

**Example 1 — Figma extraction complete (Entry 1)**:
```
✓ Step 5 of ~12 — Extracted brand tokens from Figma.

  What: Pulled primary #C41E3A, secondary #1A1A1A, accent #FFB81C, font Inter, radius 8px.
  Why:  These tokens become the LWC's CSS variables, so the card matches your brand instead of rendering generic gray/white.
  Next: Step 6 — I'll ask for a naming prefix.

? · C=state · S=switch path
```

**Example 2 — HTML transform applied (Entry 2)**:
```
✓ Step 4 of ~11 — Rewrote 3 button handlers for LWC.

  What: Changed <button onclick="handleClick()"> → <button onclick={handleClick}> across 3 buttons in your shoppingCarousel.html.
  Why:  LWC binds handlers as method references at compile time; parens would trigger eval at parse time and fail the build.
  Next: Step 5 — I'll extract your inline styles into a scoped .css sibling file.

? · C=state · S=switch path
```

**Example 3 — @api value patch (Entry 3 retrofit)**:
```
✓ Step 6 of ~9 — Patched @api value into a reactive getter/setter.

  What: Replaced `@api value;` with a getter/setter pair that re-parses the incoming DTO's productsJSON on every update.
  Why:  The chat client can update value after mount; a plain @api prop reads once and never re-renders. Failure Mode #9 in experience-cloud-site-builder.
  Next: Step 7 — I'll verify your .js-meta.xml has the lightning__AgentforceOutput target and a targetConfigs binding.

Type R for details on Failure Mode #9.

? · C=state · S=switch path · V=verify org
```

## Progress-label rules

Every question gets `Step N of ~M — <topic>`. The tilde is deliberate — count can shift ±2 based on answers.

**Per-entry-point step budgets:**

| Entry point | Approx steps | Range | Notes |
|---|---|---|---|
| 1 (Figma) | ~12 | 10–14 | Step 3 can loop if extraction is thin |
| 2 (HTML) | ~11 | 9–13 | Transform depth varies |
| 3 (Existing LWC) | ~9 | 6–12 | Branch A/B/C-dependent |
| 4 (Scan) | ~7 + funnel | 4–9 + entry N steps | Funnel resets N |

**When to update M mid-flow:**
- ±2 → keep the tilde
- ±3+ → print an explicit "Step count updated" line

**Funnel from Entry 4:** print "Step count reset — you're now in Entry <N>, Step <M> of ~<K>."

Full rules: `references/progress-labels.md`.

## Failure-mode crosswalk

`experience-cloud-site-builder` §C has 17 numbered failure modes plus a bonus. This skill cites them by number and lets the user type `R` for the details.

**Detection hooks per entry point** (what the skill proactively checks for):

| Entry | Failure Modes proactively checked |
|---|---|
| 1 (Figma) | #8 (image host → CspTrustedSite), #9 (@api value setter), #12 (targetConfigs) |
| 2 (HTML) | #9, #10 (single connectedCallback), #12, #8 |
| 3 (Existing LWC) | All of #7, #9, #10, #12 — state detection catches upfront |
| 4 (Scan) | No direct checks — funnels to picked entry |

Full crosswalk (all 17 + bonus, with symptom-to-diagnosis mapping): `references/failure-mode-crosswalk.md`.

**The `R=details` handler:** when a Failure Mode has been cited in the last turn, `R` prints the corresponding §C section from `experience-cloud-site-builder` verbatim. If nothing has been cited: "Nothing cited yet — I'll surface R inline when I reference a specific Failure Mode."

---

## Debug Log format

When the build hits an unexpected issue that isn't already documented in `experience-cloud-site-builder` §C, log it in the state canvas under a `## Debug Log` section. Format each entry:

```markdown
### DL-<N> — <one-line title>
**Date:** YYYY-MM-DD
**Entry point:** <1/2/3/4>
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
- [ ] Entry point picked and state canvas populated

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
- [ ] Every image URL in Piece 4 verified 200 before deploy
- [ ] Agent bundle validated, published, activated (Employee type)
- [ ] Permset assigned to CLI admin user (omit `--on-behalf-of` for Preview flow)

**Manual (Preview path)**
- [ ] Trusted URL(s) added for each image host (img-src only, CSP Context = All, Active)
- [ ] Preview verified: Setup → Agents → [Agent Label] → Open in Builder → Preview → paste the recorded test prompt

**Verify — always end with an explicit test prompt**
- [ ] Test prompt (from state canvas) has been printed to the user verbatim, e.g.:
  ```
  Test prompt to paste into Preview:
  show me the best cookware under $100
  ```
- [ ] Card renders inside chat bubble (not raw JSON)
- [ ] Images load correctly (all 4 slots — no blank slots)
- [ ] No console errors in Builder

**Documentation**
- [ ] `BUILD_PROCESS.md` exported
- [ ] `LWC_BUILD_STATE.md` final version saved
- [ ] Any DL entries reviewed

---

*End of SKILL.md. For deep-dive references, see `references/`. For examples, see `assets/examples/`.*
