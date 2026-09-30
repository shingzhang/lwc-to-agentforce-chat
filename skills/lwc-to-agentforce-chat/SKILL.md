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
  version: "0.6.0"
  last_updated: "2026-09-29"
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

`Figma or PNG → approved HTML preview → LWC → complete Agentforce metadata → scoped deploy`

Do meaningful implementation work, but teach as you go. Never dump this whole file into the conversation.

## Operating rules

- Move forward on your own through the design-extraction and HTML-preview phase. Do not gate those steps behind approval. State the assumptions you made, act, and let the user correct the visible result.
- Only stop to ask when something is genuinely too ambiguous to proceed sensibly (e.g. conflicting brand signals you cannot resolve, or a missing source). Otherwise pick the most reasonable option, name it, and continue.
- Ask at most one question at a time, and only when the two rules above call for it. Label any question `Step N of ~13 — <topic>`.
- After a substantive action, print a compact `What / Why / Next` block that leads with the assumptions you made.
- The browser-reviewable HTML preview (Step 3) is the one mandatory human checkpoint in the front half: always render it, tell the user how to view it, and wait for their read of the *visible result* before creating any Salesforce source. This is a review of what they can see, not a pre-write approval.
- Still require explicit `YES` before every Salesforce source write, org mutation, validation, publish, activation, permission assignment, or deploy. These are irreversible or outward-facing and keep their own checkpoints.
- Use only fictional fixture content or user-provided brand content.
- Keep the plugin self-contained. Do not refer the user to locally installed skills or private archive paths.
- Run every Salesforce CLI command with `--json` first. Read the structured result before summarizing it.
- When a mechanism differs from expectations, retrieve a known-good component from the same org and diff it before inventing metadata.

## Persona and scope

The primary user is a **Salesforce front-end developer at a large retailer** who receives approved product-card designs from a design team and must make those cards render inside Agentforce chat. They know LWC but should not have to memorize the cross-metadata wiring between Apex, Lightning Types, GenAI Functions, and Agent Script.

This workflow produces a shopping carousel or product-picks card. It can adapt the names and fields to a nearby retail card, but it should not grow into a general-purpose Agentforce builder.

## Checkpoints

There are only three kinds of mandatory checkpoint. Everything else proceeds autonomously with stated assumptions.

1. **The visual review (Step 3)** — always render the HTML preview and wait for the user's read of what they can see.
2. **The real deploy (Step 13)** — one `YES` before mutating the org.
3. **Going live (Step 13)** — one `YES` before publish + activate + assign, shown together.

At those checkpoints, show the path or command and enough content to review:

```text
Step N of ~13 — <topic>

<path or command>
<first ~30 lines, or the complete short file/command>

Reply YES to proceed, N to stop, or describe changes.
```

Never interpret an earlier `YES` as approval for a later critical action. Local source writes, extraction, and read-only/dry-run commands are not checkpoints — do them and report what you did.

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

Do not show a persistent options menu. If the user asks for status, print the state. Verification and documentation are ordinary numbered steps, not hidden letter commands.

## Guided flow

### Step 1 — Capture the design source

If the user already supplied a Figma URL, MCP node ID, or image path, acknowledge it and continue. Otherwise ask:

```text
Step 1 of ~13 — Paste your retail card design.

Send one of:
- a Figma share link
- a Figma MCP node ID (file_key:node_id)
- a local PNG/JPG path
```

### Step 2 — Extract a Brand Summary

Delegate extraction to the bundled `figma-extractor` agent automatically — no approval gate. Pass:

- `source`: the original input
- `resolved_at`: current ISO timestamp
- `webfetch_approved`: `true` when the user supplied a public URL themselves (they chose to share it); otherwise `false`

Routing:

1. Connected Figma MCP: delegate immediately; MCP handles the design link.
2. Public Figma URL without MCP: delegate with WebFetch on the user-supplied URL — no extra confirmation, since the user pasted it.
3. Figma editor URLs such as `figma.com/design/...?...m=dev` are canvas apps and generally do not yield useful WebFetch content. If MCP is unavailable and WebFetch returns nothing usable, that is a genuine ambiguity — ask for MCP authentication or a PNG.
4. Local PNG/JPG: delegate directly.

The agent returns structured JSON. Present its Brand Summary as the assumptions you are proceeding on, and continue to the HTML preview without waiting for approval. Call out anything the extractor flagged as invented or low-confidence so the user can catch it at the visual review. Only stop here if the extraction failed or the source is unusable.

Teaching block:

```text
What: Extracted concrete color, type, spacing, radius, shadow, and layout tokens.
Why: Those tokens drive both the reviewable HTML and the final scoped LWC CSS.
Next: I’ll render a browser-openable HTML version before generating Salesforce files.
```

### Step 3 — Write and review the HTML preview

Write one self-contained `<componentName>.preview.html` with inline CSS and realistic fictional retail products. It must mirror the inferred structure and use the extracted tokens. External product images must be user-provided and verified; otherwise use stable local or inline placeholders.

Write the file directly — no pre-write approval. Then state the concrete assumptions you baked in (products, colors treated as chrome vs. brand, any invented content) and tell the user exactly how to view it:

```text
open <path>
```

This is the one mandatory human checkpoint in the front half — a review of the *visible result*, not a pre-write gate:

```text
Step 3 of ~13 — Open the preview above. Does it match the design?

Reply YES to approve, or describe edits. If you request changes, regenerate and re-open. This step stays here until you approve.
```

Do not create any Salesforce source until the user approves what they saw.

### Step 4 — Transform approved HTML to an LWC renderer

Apply `references/html-to-lwc-transforms.md`. Generate `.html`, `.css`, `.js`, and `.js-meta.xml` and write them directly — these are local, reversible source files, not a critical checkpoint. Print a short `What / Why / Next` block naming the four paths afterward.

The JavaScript must use a reactive `@api value` getter/setter. The metadata must bind the renderer to the same Lightning Type name used later:

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

### Step 5 — Name the artifacts

State the API names you are using and proceed — no approval gate. Derive them from the component; use these defaults unless the design clearly calls for different ones:

```text
Using these API names (tell me if you want different ones):

LWC: retailShoppingCarousel
Apex DTO: RetailShoppingCarouselData
Apex service: RetailShoppingCarouselService
Lightning Type: Retail_ShoppingCarousel
GenAI Function: Get_Shopping_Carousel
Agent bundle: RetailShoppingAgent
Permission set: Retail_Shopping_Carousel_Access
```

Fold this into the same turn as the Step 3 visual review when you can, so the user can correct names and visuals at one checkpoint. From here on, every reference must use these names exactly; if the user renames later, update all references.

### Step 6 — Apex DTO

Preview and, after `YES`, write the DTO plus its `.cls-meta.xml`:

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

Write the DTO and its metadata directly, then note the paths in a `What / Why / Next` block. No approval gate — this is local source.

### Step 7 — Lightning Type bundle

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

Write all three files directly, then note the paths. No approval gate — this is local source.

### Step 8 — Write the approved LWC bundle

Re-preview final paths and the important pairings:

- LWC metadata `sourceType`: `c__Retail_ShoppingCarousel`
- Lightning Type renderer definition: `c/retailShoppingCarousel`
- LWC JS reads `value.productsJSON`
- Apex DTO exposes `productsJSON`

Write (or reconcile) the final four-file LWC bundle directly and confirm the pairings above hold. No approval gate — this is local source.

### Step 9 — Invocable Apex service

Preview and create the class plus `.cls-meta.xml`. Adapt fields to the approved card, while preserving the wrapper names that Agent Script will use:

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

Write the class and its metadata directly, then note the paths. No approval gate — this is local source.

### Step 10 — GenAI Function

Generate every file the wiring references.

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

Write the GenAI Function metadata and both schemas directly, then note the paths. No approval gate — this is local source.

### Step 11 — Complete AiAuthoringBundle

Do not handcraft a partial bundle. Run this command directly — it scaffolds local files, not an org change:

```bash
sf agent generate authoring-bundle --json --no-spec --name "Retail Shopping Agent" --api-name RetailShoppingAgent
```

Run it from the project root. Confirm both generated files exist:

- `force-app/main/default/aiAuthoringBundles/RetailShoppingAgent/RetailShoppingAgent.agent`
- `force-app/main/default/aiAuthoringBundles/RetailShoppingAgent/RetailShoppingAgent.bundle-meta.xml`

Then preview the complete `.agent` edit. Its action must include this current contract:

```yaml
actions:
  get_shopping_carousel:
    description: "Returns products for a retail category"
    inputs:
      category: string
        description: "Retail product family to browse"
        label: "category"
        is_required: True
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
    target: "apex://RetailShoppingCarouselService"
    label: "Get Shopping Carousel"
    require_user_confirmation: False
    include_in_progress_indicator: True
    progress_indicator_message: "Finding products..."
    source: "Get_Shopping_Carousel"
```

Preserve the generated `config`, `system`, router, and topic structure. Add the action to a complete topic and reference it from that topic’s reasoning/actions. Write the edited `.agent` directly, then note the path. No approval gate — this is local source.

### Step 12 — Permission set and conditional CSP

Create the permission set that the deploy flow later assigns:

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

If the approved design uses external images, also generate a `CspTrustedSite` for each verified host and include those paths in the deploy scope. If it uses local or inline placeholders, do not create or deploy CSP metadata.

Write the permission set and any required trusted-site metadata directly, then note the paths. No approval gate — this is local source. (Assignment to a user happens later in Step 13 and keeps its own checkpoint.)

### Step 13 — Validate, dry-run, deploy, and verify

Validation and the dry-run do not change the org, so run them automatically and report the results:

```bash
sf agent validate authoring-bundle --json --api-name RetailShoppingAgent
sf project deploy start --json --dry-run --source-dir force-app/main/default/classes --source-dir force-app/main/default/lightningTypes/Retail_ShoppingCarousel --source-dir force-app/main/default/lwc/retailShoppingCarousel --source-dir force-app/main/default/genAiFunctions/Get_Shopping_Carousel --source-dir force-app/main/default/aiAuthoringBundles/RetailShoppingAgent --source-dir force-app/main/default/permissionsets/Retail_Shopping_Carousel_Access.permissionset-meta.xml --target-org <alias>
```

The real deploy **is** the first critical checkpoint. Show the real deploy command (same explicit source scope) and require `YES`:

```text
Step 13 of ~13 — Validation and dry-run passed. Run the real scoped deploy to <alias>?
```

When Claude runs that approved deploy through its Bash tool, the bundled PreToolUse hook checks image URLs embedded in scoped Apex files and blocks known 4xx or 5xx responses. The hook does **not** inspect commands typed manually in another terminal; say this plainly.

After deployment, going live is one consolidated critical checkpoint. Show all three commands together and require a single `YES` before running them in order:

```text
Step 13 of ~13 — Deploy succeeded. Publish, activate, and assign the permission set to the bot user? (runs all three below)
```

```bash
sf agent publish authoring-bundle --json --api-name RetailShoppingAgent --target-org <alias>
sf agent activate --json --api-name RetailShoppingAgent --target-org <alias>
sf org assign permset --json --name Retail_Shopping_Carousel_Access --target-org <alias> --on-behalf-of <BotUserUsername>
```

Do not claim completion until the user tests a prompt in the deployed chat surface and confirms the card rendered. A draft Agent Builder preview may not render a CLT output card; test the committed, activated agent in its deployed surface.

## Teaching block format

Use after each substantive action:

```text
✓ Step N of ~13 — <completed action>.

What: <one concrete sentence>.
Why: <one constraint or failure prevented>.
Next: <next numbered question>.
```

See `references/teaching-blocks.md` and `references/failure-mode-crosswalk.md` for troubleshooting, but keep the live response concise.

## Final completeness check

- HTML preview was explicitly approved.
- Apex DTO and service names match the Lightning Type and GenAI Function.
- `schema.json` contains `lightning:type: @apexClassType/c__...`.
- `renderer.json` uses `renderer.componentOverrides.$.definition`.
- LWC metadata has `lightning__AgentforceOutput` and the matching `sourceType`.
- Agent Script output is `object`, includes `complex_data_type_name`, `is_displayable: True`, and `filter_from_agent: False`.
- Agent Script uses `target: "apex://..."` and `source` matches the GenAI Function developer name.
- The complete generated authoring bundle exists.
- The permission set exists before deployment and is assigned to the bot user.
- Every deploy path exists; conditional CSP paths are included only if created.
- Validation and dry-run passed before real deployment.
- The activated agent rendered the card in the target chat surface.

This metadata shape is a reduced adaptation of Salesforce’s official Agent Script Recipes Custom Lightning Types example. Keep names customized, but preserve the wiring contract.
