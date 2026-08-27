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
  version: "0.5.0"
  last_updated: "2026-08-27"
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

- Ask exactly one question at a time.
- Label every question `Step N of ~13 — <topic>`.
- After a substantive action, print a compact `What / Why / Next` block.
- Require explicit `YES` before every file write, URL fetch through WebFetch, org mutation, validation, publish, activation, permission assignment, or deploy.
- Step 3—the browser-reviewable HTML preview—is mandatory. Do not create Salesforce source until the user approves it.
- Use only fictional fixture content or user-provided brand content.
- Keep the plugin self-contained. Do not refer the user to locally installed skills or private archive paths.
- Run every Salesforce CLI command with `--json` first. Read the structured result before summarizing it.
- When a mechanism differs from expectations, retrieve a known-good component from the same org and diff it before inventing metadata.

## Persona and scope

The primary user is a **Salesforce front-end developer at a large retailer** who receives approved product-card designs from a design team and must make those cards render inside Agentforce chat. They know LWC but should not have to memorize the cross-metadata wiring between Apex, Lightning Types, GenAI Functions, and Agent Script.

This workflow produces a shopping carousel or product-picks card. It can adapt the names and fields to a nearby retail card, but it should not grow into a general-purpose Agentforce builder.

## Checkpoints

At every checkpoint, show the path or command and enough content to review:

```text
Step N of ~13 — <topic>

About to <action>. Preview:
<path or command>
<first ~30 lines, or the complete short file/command>

Reply YES to proceed, N to stop, or describe changes.
```

Never interpret an earlier `YES` as approval for a later action.

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

Always delegate extraction to the bundled `figma-extractor` agent. Pass:

- `source`: the original input
- `resolved_at`: current ISO timestamp
- `webfetch_approved`: `false` unless the user explicitly approved the exact URL in this step

Routing:

1. Connected Figma MCP: delegate immediately; MCP handles the design link.
2. Public Figma URL without MCP: show the exact URL and ask `Step 2 of ~13 — May I send this URL to WebFetch?`
3. Only after `YES`, delegate again with `webfetch_approved: true`.
4. Figma editor URLs such as `figma.com/design/...?...m=dev` are canvas apps and generally do not yield useful WebFetch content. Ask for MCP authentication or a PNG instead.
5. Local PNG/JPG: delegate with no network approval needed.

The agent must return structured JSON. Present its Brand Summary and ask:

```text
Step 2 of ~13 — Are these extracted brand tokens and the inferred retail pattern correct?

Reply YES, or list corrections.
```

Teaching block:

```text
What: Extracted concrete color, type, spacing, radius, shadow, and layout tokens.
Why: Those tokens drive both the reviewable HTML and the final scoped LWC CSS.
Next: I’ll render a browser-openable HTML version before generating Salesforce files.
```

### Step 3 — Write and review the HTML preview

Create one self-contained `<componentName>.preview.html` with inline CSS and realistic fictional retail products. It must mirror the inferred structure and use the extracted tokens. External product images must be user-provided and verified; otherwise use stable local or inline placeholders.

Preview the path and first ~30 lines, then ask `Step 3 of ~13 — Write this HTML preview?` After `YES`, write it and tell the user how to open it. Ask:

```text
Step 3 of ~13 — Does the browser preview match the design?

Reply YES to approve it, or describe edits. This step stays at Step 3 until approved.
```

Do not proceed without approval.

### Step 4 — Transform approved HTML to an LWC renderer

Apply `references/html-to-lwc-transforms.md`. Generate `.html`, `.css`, `.js`, and `.js-meta.xml`. Preview all four; ask `Step 4 of ~13 — Write this LWC renderer bundle?`

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

### Step 5 — Confirm names

Ask one labeled question containing proposed names:

```text
Step 5 of ~13 — Use these API names?

LWC: retailShoppingCarousel
Apex DTO: RetailShoppingCarouselData
Apex service: RetailShoppingCarouselService
Lightning Type: Retail_ShoppingCarousel
GenAI Function: Get_Shopping_Carousel
Agent bundle: RetailShoppingAgent
Permission set: Retail_Shopping_Carousel_Access

Reply YES or provide replacements.
```

From this point forward, every reference must use the confirmed names exactly.

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

Question: `Step 6 of ~13 — Write the Apex DTO and metadata?`

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

Question: `Step 7 of ~13 — Write the Apex-bound Lightning Type bundle?`

### Step 8 — Write the approved LWC bundle

Re-preview final paths and the important pairings:

- LWC metadata `sourceType`: `c__Retail_ShoppingCarousel`
- Lightning Type renderer definition: `c/retailShoppingCarousel`
- LWC JS reads `value.productsJSON`
- Apex DTO exposes `productsJSON`

Question: `Step 8 of ~13 — Write the final four-file LWC bundle?`

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

Question: `Step 9 of ~13 — Write the Invocable Apex service and metadata?`

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

Question: `Step 10 of ~13 — Write the GenAI Function metadata and schemas?`

### Step 11 — Complete AiAuthoringBundle

Do not handcraft a partial bundle. Preview this command and require `YES`:

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

Preserve the generated `config`, `system`, router, and topic structure. Add the action to a complete topic and reference it from that topic’s reasoning/actions. Preview the full edited `.agent`; ask `Step 11 of ~13 — Write this complete Agent Script bundle?`

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

Question: `Step 12 of ~13 — Write the permission set and any required trusted-site metadata?`

### Step 13 — Validate, dry-run, deploy, and verify

First run local and org-aware validation only after a dedicated `YES`:

```bash
sf agent validate authoring-bundle --json --api-name RetailShoppingAgent
sf project deploy start --json --dry-run --source-dir force-app/main/default/classes --source-dir force-app/main/default/lightningTypes/Retail_ShoppingCarousel --source-dir force-app/main/default/lwc/retailShoppingCarousel --source-dir force-app/main/default/genAiFunctions/Get_Shopping_Carousel --source-dir force-app/main/default/aiAuthoringBundles/RetailShoppingAgent --source-dir force-app/main/default/permissionsets/Retail_Shopping_Carousel_Access.permissionset-meta.xml --target-org <alias>
```

Question: `Step 13 of ~13 — Run validation and this scoped dry-run?`

If both pass, show a separate real deploy command with the same explicit source scope and ask:

```text
Step 13 of ~13 — The dry-run passed. Run the real scoped deploy?
```

When Claude runs that approved deploy through its Bash tool, the bundled PreToolUse hook checks image URLs embedded in scoped Apex files and blocks known 4xx or 5xx responses. The hook does **not** inspect commands typed manually in another terminal; say this plainly.

After deployment, preview each command separately. Ask these three labeled questions in order, and wait for a new `YES` each time:

1. `Step 13 of ~13 — Publish the deployed authoring bundle?`
2. `Step 13 of ~13 — Activate the published agent?`
3. `Step 13 of ~13 — Assign the permission set to this bot user?`

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
