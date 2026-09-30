---
name: lwc-to-agentforce-chat
description: >
  Turn a retail Figma design into a Lightning Web Component that renders inside
  an Agentforce chat response. Extracts brand tokens, requires a browser-reviewable
  HTML preview, then creates the complete Salesforce metadata wiring: Apex DTO,
  Lightning Type, LWC renderer, Invocable Apex, GenAI Function, Agent Script
  authoring bundle, and permission set.

  TRIGGER when: a Salesforce front-end developer has a Figma URL, Figma export,
  or PNG/JPG retail mockup and wants it rendered in an Agentforce chat bubble.

  DO NOT TRIGGER when: the destination is a Lightning page rather than Agentforce
  chat; the user only wants an audit; or there is no Figma/image source.
license: MIT
experimental: true
metadata:
  version: "0.7.0"
  last_updated: "2026-09-30"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
---

# lwc-to-agentforce-chat

Guide a retail-enterprise Salesforce front-end developer through one path:

`Figma or PNG → approved HTML preview → LWC → complete Agentforce metadata → live agent`

Do meaningful implementation work, but teach as you go. Never dump this whole file into the conversation.

## How this workflow counts "steps"

A step you show the user exists **only when you need them** — a question to answer or something to look at. Everything else — extracting tokens, writing files, scaffolding, transforming, validating, dry-running — is you working; do it under one banner and report it as brief "done" notes, not as steps that imply the user's involvement.

There are **~5 check-ins** in a full build, plus the final render confirmation:

1. **Confirm the source and brand read** — the design source, then the extracted Brand Summary you're proceeding on.
2. **Review the HTML preview** — the one mandatory visual checkpoint. In the same turn: confirm the API names (including the **agent name**), and provide + validate the real product image URLs.
3. **Approve the real deploy** — one `YES` before mutating the org.
4. **Approve go-live** — one `YES` for the publish/activate/assign path, or the Builder code-view path when publish is blocked.
5. **Confirm the card rendered** — you test the deployed surface and confirm with the user.

Show the marker `Check-in N of ~5 — <topic>` on the interaction points, and lead every substantive response with a one-line progress marker so the user never has to guess whether a pause is a deliberate checkpoint or lost state. Internal build work between check-ins 2 and 3 is reported as a running sub-checklist, not as numbered steps.

## Operating rules

- Move forward on your own through extraction, the HTML preview, the LWC transform, and all metadata generation. Do not gate that work behind approval. State the assumptions you made, act, and let the user correct the visible result at a check-in.
- Only stop to ask when something is genuinely too ambiguous to proceed sensibly (conflicting brand signals you cannot resolve, a missing source, a broken image URL) or when you hit one of the ~5 check-ins. Otherwise pick the most reasonable option, name it, and continue.
- Ask at most one question at a time. Label any question `Check-in N of ~5 — <topic>`.
- After a substantive action, print a compact `What / Why / Next` block that leads with the assumptions you made.
- Still require explicit `YES` before every org mutation: real deploy, publish, activation, permission assignment. These are irreversible or outward-facing and keep their own checkpoints. Local source writes, extraction, and read-only/dry-run commands are not checkpoints — do them and report what you did.
- Never interpret an earlier `YES` as approval for a later critical action.
- Use only fictional fixture content or user-provided brand content.
- Keep the plugin self-contained. Do not refer the user to locally installed skills or private archive paths.
- Run every Salesforce CLI command with `--json` first. Read the structured result before summarizing it.
- When a mechanism differs from expectations, retrieve a known-good component from the same org and diff it before inventing metadata.

## Persona and scope

The primary user is a **Salesforce front-end developer at a large retailer** who receives approved product-card designs from a design team and must make those cards render inside Agentforce chat. They know LWC but should not have to memorize the cross-metadata wiring between Apex, Lightning Types, GenAI Functions, and Agent Script.

This workflow produces a shopping carousel or product-picks card. It can adapt the names and fields to a nearby retail card, but it should not grow into a general-purpose Agentforce builder.

## State

If an `sfdx-project.json` exists, maintain `LWC_BUILD_STATE.md` beside it. Read before updating and preserve user edits. In fixture/local-preview mode, keep state in chat and do not require a Salesforce project.

Track these artifacts explicitly:

```markdown
## Generated artifacts
- [ ] Apex DTO class
- [ ] Lightning Type bundle (schema + renderer + metadata)
- [ ] LWC renderer bundle
- [ ] Invocable Apex service
- [ ] GenAI Function (metadata + input/output schemas)
- [ ] AiAuthoringBundle (.agent + bundle metadata)
- [ ] Permission set
- [ ] CspTrustedSite, only when external image hosts are used
```

If the user asks for status, print the state. Verification and documentation are ordinary actions, not hidden letter commands.

---

## Check-in 1 — Confirm the source and the brand read

### Capture the design source

If the user already supplied a Figma URL, MCP node ID, or image path, acknowledge it and continue. Otherwise ask:

```text
Check-in 1 of ~5 — Paste your retail card design.

Send one of:
- a Figma share link
- a Figma MCP node ID (file_key:node_id)
- a local PNG/JPG path
```

### Extract the Brand Summary (internal work — no gate)

Delegate extraction to the bundled `figma-extractor` agent automatically. Pass:

- `source`: the original input
- `resolved_at`: current ISO timestamp
- `webfetch_approved`: `true` when the user supplied a public URL themselves (they chose to share it); otherwise `false`

Routing:

1. Connected Figma MCP: delegate immediately; MCP handles the design link.
2. Public Figma URL without MCP: delegate with WebFetch on the user-supplied URL — no extra confirmation, since the user pasted it.
3. Figma editor URLs such as `figma.com/design/...?...m=dev` are canvas apps and generally do not yield useful WebFetch content. If MCP is unavailable and WebFetch returns nothing usable, that is a genuine ambiguity — ask for MCP authentication or a PNG.
4. Local PNG/JPG: delegate directly.

The agent returns structured JSON. Present its Brand Summary as the assumptions you are proceeding on. Call out anything the extractor flagged as invented or low-confidence so the user can catch it at the visual review. Continue to the preview without a separate approval gate — the visual review is where the user confirms this read.

```text
✓ Check-in 1 — Extracted concrete color, type, spacing, radius, shadow, and layout tokens.

What: Read the design into a Brand Summary (colors, type, spacing, radius, shadow, layout).
Why: Those tokens drive both the reviewable HTML and the final scoped LWC CSS.
Next: I’ll render a browser-openable HTML preview for you to review.
```

---

## Check-in 2 — Review the HTML preview (names + images in the same turn)

This is the **one mandatory human checkpoint in the front half** — a review of the *visible result*, not a pre-write gate. Always render it, always wait for the user's read before creating any Salesforce source.

### Write the preview

Write one self-contained `<componentName>.preview.html` with inline CSS and realistic fictional retail products. It must mirror the inferred structure and use the extracted tokens. Write the file directly — no pre-write approval.

**Images live here, not later.** On the first pass, use stable local or inline placeholders for product images. Then, in the same turn, ask the user for the real product image URLs (one at a time is fine) so they render in the preview the user actually reviews:

- When the user provides a URL, put it in the preview and regenerate. The bundled **preview-time hook** (`verify-preview-images.sh`) validates every `http(s)` image URL in the `*.preview.html` on write and blocks any that return 4xx/5xx — so a broken or hotlink-blocked image is caught immediately, before the user reviews it. If the hook blocks, re-copy the address (WS product page → right-click the main image → "Copy Image Address"), or fall back to a stable placeholder for that slot, then re-write.
- **Record each external image host** as you go (e.g. `assets.wsimgs.com`, `images.unsplash.com`). The downstream `CspTrustedSite` metadata is emitted from this recorded list — do not re-derive it later.
- `assets.wsimgs.com` (Williams-Sonoma CDN) serves fine into a local preview; some CDNs hotlink-block and will 403 — treat that as a "provide a different URL" prompt, not a build error.

### Confirm the names — including the agent name

Fold naming into this same turn so the user corrects visuals, names, and the agent name at one checkpoint. State the derived technical names and proceed with them unless corrected; but **explicitly ask for the agent name** rather than defaulting it silently:

```text
Using these API names (tell me if you want different ones):

LWC: retailShoppingCarousel
Apex DTO: RetailShoppingCarouselData
Apex service: RetailShoppingCarouselService
Lightning Type: Retail_ShoppingCarousel
GenAI Function: Get_Shopping_Carousel
Permission set: Retail_Shopping_Carousel_Access

And what should I name the AGENT? This is the artifact you'll find in
Setup → Agents and demo. I'll use "Retail Shopping Agent" / RetailShoppingAgent
unless you'd prefer something else.
```

Sanitize whatever the user gives into a valid API name for `developer_name` — alphanumeric + underscores, hyphens become underscores — and keep the literal string as the display label. Example: the user says `ShopperDemo9-30` → API name `ShopperDemo9_30`, label `"ShopperDemo9-30"`. From here on, every reference uses these names exactly; if the user renames later, update all references.

### The visual review gate

```text
Check-in 2 of ~5 — Open the preview above. Does it match the design?

open <path>

Reply YES to approve, or describe edits. If you request changes (including image
swaps), regenerate and re-open. This step stays here until you approve.
```

Do not create any Salesforce source until the user approves what they saw.

---

## Build phase — I do the wiring (no stops between Check-ins 2 and 4)

Everything in this phase is local source generation and read-only validation. Do it directly and report a running sub-checklist. No approval gates here.

```text
Building the Salesforce metadata (no action needed from you):
⬜ LWC renderer bundle    ⬜ Apex DTO         ⬜ Lightning Type bundle
⬜ Invocable Apex service ⬜ GenAI Function   ⬜ Authoring bundle (.agent)
⬜ Permission set + CSP   ⬜ Validate + dry-run
```

### Transform approved HTML → LWC renderer

Apply `references/html-to-lwc-transforms.md`. Generate `.html`, `.css`, `.js`, and `.js-meta.xml`. The JavaScript must use a reactive `@api value` getter/setter. The metadata binds the renderer to the same Lightning Type name used later:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <isExposed>true</isExposed>
    <masterLabel>Retail Shopping Carousel Renderer</masterLabel>
    <targets>
        <target>lightning__AgentforceOutput</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__AgentforceOutput">
            <sourceType name="c__Retail_ShoppingCarousel"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

Keep a single `connectedCallback`, use stable keys for loops, move inline handlers into JS, and hide or replace failed images.

### Apex DTO

```apex
@JsonAccess(serializable='always' deserializable='always')
global class RetailShoppingCarouselData {
    @AuraEnabled global String productsJSON;

    global RetailShoppingCarouselData() {}

    global RetailShoppingCarouselData(String productsJSON) {
        this.productsJSON = productsJSON;
    }
}
```

Write the DTO plus its `.cls-meta.xml`.

### Lightning Type bundle

Create all three files. The schema binds the Lightning Type to the Apex class; do not put an ad hoc JSON property schema here.

`force-app/main/default/lightningTypes/Retail_ShoppingCarousel/schema.json`

```json
{
  "title": "Retail Shopping Carousel",
  "description": "Structured retail product carousel output",
  "lightning:type": "@apexClassType/c__RetailShoppingCarouselData"
}
```

`lightningDesktopGenAi/renderer.json`

```json
{
  "renderer": {
    "componentOverrides": {
      "$": {
        "definition": "c/retailShoppingCarousel"
      }
    }
  }
}
```

`Retail_ShoppingCarousel.lightningTypeBundle-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningTypeBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>66.0</apiVersion>
    <masterLabel>Retail Shopping Carousel</masterLabel>
    <description>Renders product results in Agentforce chat.</description>
</LightningTypeBundle>
```

Confirm the important pairings hold as you write the final LWC bundle:

- LWC metadata `sourceType`: `c__Retail_ShoppingCarousel`
- Lightning Type renderer definition: `c/retailShoppingCarousel`
- LWC JS reads `value.productsJSON`
- Apex DTO exposes `productsJSON`

### Invocable Apex service

Adapt fields to the approved card, while preserving the wrapper names Agent Script will use:

```apex
public with sharing class RetailShoppingCarouselService {
    public class Request {
        @InvocableVariable(required=true)
        public String category;
    }

    public class Response {
        @InvocableVariable public RetailShoppingCarouselData carousel;
        @InvocableVariable public String narrative;
    }

    @InvocableMethod(label='Get Shopping Carousel')
    public static List<Response> getCarousel(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            List<Product2> products = [
                SELECT Id, Name, ProductCode, Family
                FROM Product2
                WHERE Family = :request.category
                LIMIT 4
            ];
            Response response = new Response();
            response.carousel = new RetailShoppingCarouselData(JSON.serialize(products));
            response.narrative = 'Here are ' + products.size() + ' picks in ' + request.category + '.';
            responses.add(response);
        }
        return responses;
    }
}
```

### GenAI Function

`genAiFunctions/Get_Shopping_Carousel/Get_Shopping_Carousel.genAiFunction-meta.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<GenAiFunction xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Returns retail products for a category</description>
    <developerName>Get_Shopping_Carousel</developerName>
    <invocationTarget>RetailShoppingCarouselService</invocationTarget>
    <invocationTargetType>apex</invocationTargetType>
    <isConfirmationRequired>false</isConfirmationRequired>
    <isIncludeInProgressIndicator>true</isIncludeInProgressIndicator>
    <localDeveloperName>Get_Shopping_Carousel</localDeveloperName>
    <masterLabel>Get Shopping Carousel</masterLabel>
    <progressIndicatorMessage>Finding products...</progressIndicatorMessage>
</GenAiFunction>
```

`input/schema.json`

```json
{
  "required": ["category"],
  "unevaluatedProperties": false,
  "properties": {
    "category": {
      "title": "category",
      "description": "Retail product family to browse",
      "lightning:type": "lightning__textType",
      "lightning:isPII": false
    }
  },
  "lightning:type": "lightning__objectType"
}
```

`output/schema.json`

```json
{
  "unevaluatedProperties": false,
  "properties": {
    "carousel": {
      "title": "carousel",
      "description": "Structured products for the carousel renderer",
      "lightning:type": "c__Retail_ShoppingCarousel",
      "lightning:isPII": false,
      "copilotAction:isDisplayable": true,
      "copilotAction:isUsedByPlanner": true,
      "copilotAction:useHydratedPrompt": false
    },
    "narrative": {
      "title": "narrative",
      "description": "Short spoken introduction",
      "lightning:type": "lightning__textType",
      "lightning:isPII": false,
      "copilotAction:isDisplayable": false,
      "copilotAction:isUsedByPlanner": true,
      "copilotAction:useHydratedPrompt": false
    }
  },
  "lightning:type": "lightning__objectType"
}
```

### Complete AiAuthoringBundle

Do not handcraft a partial bundle. Scaffold it with the generator (local files, not an org change), using the agent name confirmed at Check-in 2:

```bash
sf agent generate authoring-bundle --json --no-spec --name "<Agent Label>" --api-name <AgentApiName>
```

Confirm both generated files exist:

- `force-app/main/default/aiAuthoringBundles/<AgentApiName>/<AgentApiName>.agent`
- `force-app/main/default/aiAuthoringBundles/<AgentApiName>/<AgentApiName>.bundle-meta.xml`

Then edit the `.agent`. Match the CLI's current Agent Script grammar: define the action inside a **subagent-level `actions:` block** and reference it from that subagent's `reasoning.actions` via `@actions.<name>`. The action's render contract:

```yaml
actions:
    get_shopping_carousel:
        description: "Returns products for a retail category"
        label: "Get Shopping Carousel"
        target: "apex://RetailShoppingCarouselService"
        include_in_progress_indicator: True
        progress_indicator_message: "Finding products..."
        inputs:
            category: string
                description: "Retail product family to browse"
                label: "category"
                is_required: True
                complex_data_type_name: "lightning__textType"
        outputs:
            carousel: object
                description: "Structured products for display"
                label: "carousel"
                complex_data_type_name: "c__Retail_ShoppingCarousel"
                filter_from_agent: False
                is_displayable: True
            narrative: string
                description: "Short spoken introduction"
                label: "narrative"
                filter_from_agent: False
                is_displayable: False
```

Preserve the generated `system`, `config`, `variables`, router, and subagent scaffolding. Set `config.default_agent_user` to a real, active username. Add the action to a subagent and reference it from that subagent's reasoning.

### Permission set and conditional CSP

```xml
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <classAccesses>
        <apexClass>RetailShoppingCarouselData</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>RetailShoppingCarouselService</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <description>Runs the retail shopping carousel Agentforce action.</description>
    <hasActivationRequired>false</hasActivationRequired>
    <label>Retail Shopping Carousel Access</label>
    <objectPermissions>
        <allowCreate>false</allowCreate>
        <allowDelete>false</allowDelete>
        <allowEdit>false</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords>
        <object>Product2</object>
        <viewAllFields>false</viewAllFields>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
</PermissionSet>
```

Generate one `CspTrustedSite` per external image host **recorded at Check-in 2**, and include those paths in the deploy scope. If the preview used only local or inline placeholders, do not create or deploy CSP metadata.

### Validate + dry-run (read-only)

These do not change the org — run them automatically and report results:

```bash
sf agent validate authoring-bundle --json --api-name <AgentApiName>
sf project deploy start --json --dry-run --source-dir force-app/main/default/classes --source-dir force-app/main/default/lightningTypes/Retail_ShoppingCarousel --source-dir force-app/main/default/lwc/retailShoppingCarousel --source-dir force-app/main/default/genAiFunctions/Get_Shopping_Carousel --source-dir force-app/main/default/aiAuthoringBundles/<AgentApiName> --source-dir force-app/main/default/permissionsets/Retail_Shopping_Carousel_Access.permissionset-meta.xml --target-org <alias>
```

Report the sub-checklist as complete, then move to Check-in 3.

---

## Check-in 3 — Approve the real deploy

The real deploy is the first org mutation. Salesforce deploys are **transactional** — one failed component rolls back the whole deploy, so deploy the full scope together and confirm the component count. Show the command and require `YES`:

```text
Check-in 3 of ~5 — Validation and dry-run passed. Run the real scoped deploy to <alias>?
```

```bash
sf project deploy start --json --source-dir force-app/main/default/classes --source-dir force-app/main/default/lightningTypes/Retail_ShoppingCarousel --source-dir force-app/main/default/lwc/retailShoppingCarousel --source-dir force-app/main/default/genAiFunctions/Get_Shopping_Carousel --source-dir force-app/main/default/aiAuthoringBundles/<AgentApiName> --source-dir force-app/main/default/permissionsets/Retail_Shopping_Carousel_Access.permissionset-meta.xml --target-org <alias>
```

When Claude runs that approved deploy through its Bash tool, the bundled `verify-image-urls.sh` PreToolUse hook checks image URLs embedded in scoped Apex files and blocks known 4xx/5xx responses. It does **not** inspect commands typed manually in another terminal; say this plainly.

---

## Check-in 4 — Go live (branches; the CLI publish is not the only path)

Going live is one consolidated critical checkpoint. There are two paths; pick based on what the org supports. On demo/storm/scratch orgs, **prefer the code-view path outright** — CLI publish commonly 404s there.

### Path A — CLI publish/activate/assign (try first on entitled orgs)

Show all three commands together and require a single `YES`:

```text
Check-in 4 of ~5 — Deploy succeeded. Publish, activate, and assign the permission set to the bot user? (runs all three below)
```

```bash
sf agent publish authoring-bundle --json --api-name <AgentApiName> --target-org <alias>
sf agent activate --json --api-name <AgentApiName> --target-org <alias>
sf org assign permset --json --name Retail_Shopping_Carousel_Access --target-org <alias> --on-behalf-of <BotUserUsername>
```

**If `sf agent publish authoring-bundle` returns `AgentApiNotFound` / `ERROR_HTTP_404` (empty message): stop retrying.** That command calls an external SFAP API the org may not be entitled for — re-login and connected-app scope fixes will **not** clear a 404. It is an org-entitlement wall, not an auth bug. Switch to Path B (or Path C on older orgs). Full path selection, builder-generation detection, and the dead ends to skip are in `references/go-live-and-publish.md`.

### Path B — Agentforce Builder code view (the reliable path; needs no SFAP entitlement)

This is what ships on demo/storm/scratch orgs. It uses the org's own Builder save/activate — no external API. Guide the user click-by-click (drive their browser only if they have the extension connected; otherwise narrate each click):

1. **Setup → Agentforce Studio / Agents** (`/lightning/setup/EinsteinCopilot/home`) → **New Agent**.
2. Pick the **Agentforce Employee Agent** template (a clean, Preview-testable base). Enter the label + API name from Check-in 2. It drops into the graph builder as `<Name> Version 1 (Draft)` — a real agent already in the org. (If it skips the description/running-user fields and lands directly on the canvas, that's expected — set them later or leave the template defaults.)
3. Open the **`</>` code view** (top-right toolbar). It shows the agent's full Agent Script and is editable.
4. Make a **surgical** edit — do **not** paste your standalone `.agent` wholesale. The template carries scaffolding your file lacks (`agent_template`, the `current*` mutable variables, `knowledge:`, `model_config`). Keep the template body; add only:
   - one router route inside `start_agent … reasoning.actions`:
     `go_to_shopping: @utils.transition to @subagent.shopping`
   - one `subagent shopping:` block with a `reasoning.actions` binding (`get_shopping_carousel: @actions.get_shopping_carousel with category = ...`) and an `actions:` block whose action uses `target: "apex://RetailShoppingCarouselService"` and the displayable output (`complex_data_type_name: "c__Retail_ShoppingCarousel"`, `is_displayable: True`, `filter_from_agent: False`). Match the template's own grammar — it quotes I/O names (`"category": string`).
5. **Save.** This validates server-side. A clean save means the org accepted the apex action target *and* the custom Lightning Type output — the same render contract the CLI bundle uses.
6. **Activate.** (Employee-agent activate did not prompt for a running user in the reference build; if yours does, set the agent/running user.)
7. Proceed to Check-in 5 (Preview).

### Path C — classic GenAiPlanner + Bot (older orgs with no code view)

If the org's Builder shows only **Topics/Actions** with no graph and no `</>` code view, it's the older model. Build the agent as `GenAiPlanner` + `GenAiPlugin`/`GenAiFunction` + `Bot` metadata and deploy that directly — no external API. See `references/go-live-and-publish.md` (documented; not yet exercised end-to-end).

**Detecting the generation:** new builder = graph canvas with an Agent Router / subagent nodes and a `</>` Agent Script code view (`config.agent_template` like `EmployeeCopilot__AgentforceEmployeeAgent`). Old builder = a flat list of Topics and Actions, planner-based, no code view.

---

## Check-in 5 — Confirm the card rendered

Do not claim completion until the user tests a prompt in the deployed chat surface and confirms the card rendered. A draft Agent Builder preview may not render a CLT output card; test the committed, activated agent in its deployed surface (Preview → send the test prompt → confirm the carousel renders).

```text
Check-in 5 of ~5 — Open the activated agent's Preview and send: "<test prompt>".
Did the carousel card render?
```

---

## Teaching block format

Lead every substantive response with the progress marker, then after each completed action:

```text
✓ Check-in N of ~5 — <completed action>.   (or: Build phase — <sub-item> done)

What: <one concrete sentence>.
Why: <one constraint or failure prevented>.
Next: <next check-in or the remaining build sub-items>.
```

See `references/teaching-blocks.md` and `references/failure-mode-crosswalk.md` for troubleshooting, and `references/go-live-and-publish.md` for choosing the publish/go-live path when the CLI publish 404s. Keep the live response concise.

## Final completeness check

- HTML preview was explicitly approved, and every real image URL in it returned 2xx (preview-time hook passed).
- External image hosts recorded at preview time each have a `CspTrustedSite`; if placeholders only, none exist.
- Apex DTO and service names match the Lightning Type and GenAI Function.
- `schema.json` contains `lightning:type: @apexClassType/c__...`.
- `renderer.json` uses `renderer.componentOverrides.$.definition`.
- LWC metadata has `lightning__AgentforceOutput` and the matching `sourceType`.
- Agent Script output is `object`, includes `complex_data_type_name`, `is_displayable: True`, and `filter_from_agent: False`.
- Agent Script action uses `target: "apex://..."` and the referenced GenAI Function/action name matches.
- The complete generated authoring bundle exists; `config.default_agent_user` is a real active user.
- The agent name is the one the user confirmed (API name sanitized, label kept literal).
- The permission set exists before deployment and is assigned to the bot user.
- Every deploy path exists; conditional CSP paths are included only if created.
- Validation and dry-run passed before real deployment.
- The activated agent rendered the card in the target chat surface.

This metadata shape is a reduced adaptation of Salesforce’s official Agent Script Recipes Custom Lightning Types example. Keep names customized, but preserve the wiring contract.
