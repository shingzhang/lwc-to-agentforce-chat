# Example — Entry 3 (Existing LWC → chat wiring)

> Fully fictional. "Kai at WSI" is a made-up persona; `wsifde*` names are
> placeholders. No real customer code.

## Scenario

Kai (a fictional front-end developer) already has an LWC called
`wsifdePersonalizedPicks` that renders on an Experience Builder record
page. Now the team wants the same visual to appear inside Agentforce
chat when the agent recommends products. Kai does not want to rebuild
the LWC — just wire it up.

## Input

```
User: I already have wsifdePersonalizedPicks. Get it into Agentforce chat.
      Project root: ~/code/wsi-agent-demo
```

## What the skill emits

```
Step 1 of ~9 — Path picked: Entry 3 (Existing LWC → chat wiring).

✓ Step 2 of ~9 — Detected existing pieces of the 5-piece contract.

  What: Scanned force-app/main/default/. Found the LWC bundle and the
        Apex DTO. Missing: LightningType, Invocable, Agent Script action.
  Why:  The 5-piece contract needs all five pieces to render in chat.
        You have 2 of 5 — this is Branch C (partial retrofit).
  Next: Step 3 — I'll show the state table and confirm the plan.

? · C=state · S=switch path
```

## State-detection scan output

```
✓ LWC bundle:          force-app/main/default/lwc/wsifdePersonalizedPicks/
✓ Apex DTO:            force-app/main/default/classes/WsifdeProductPicksData.cls
✗ LightningType bundle: missing
✗ Invocable Apex:      missing
✗ Agent Script action: missing
```

**Recommendation: Branch C — partial retrofit. 3 pieces to add.**

## `.js-meta.xml` before / after

**Before** (targeting a record page only):

```xml
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
  <apiVersion>62.0</apiVersion>
  <isExposed>true</isExposed>
  <targets>
    <target>lightning__RecordAction</target>
  </targets>
</LightningComponentBundle>
```

**After** (adds chat target + targetConfig binding to the LightningType we
are about to create):

```xml
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
  <apiVersion>62.0</apiVersion>
  <isExposed>true</isExposed>
  <targets>
    <target>lightning__RecordAction</target>
    <target>lightning__AgentforceOutput</target>
  </targets>
  <targetConfigs>
    <targetConfig targets="lightning__AgentforceOutput">
      <sourceType name="c__Wsifde_PersonalizedPicks"/>
    </targetConfig>
  </targetConfigs>
</LightningComponentBundle>
```

## Failure modes caught proactively during retrofit

| # | What we check | When |
|---|---|---|
| **#9**  | `@api value` is a reactive getter/setter, not a plain prop | Step 6 (LWC .js patch preview) |
| **#12** | `<targetConfigs>` block binds to the new LightningType | Step 7 (.js-meta.xml diff preview) |
| **#10** | Exactly one `connectedCallback()` in the LWC .js | Step 6 (LWC .js patch preview) |

From here the skill walks Steps 3–9 (preview LightningType → preview
Invocable → preview Agent Script action → deploy checkpoint) with a
What/Why/Next block after each write. Deploys stay with Kai — the skill
never runs `sf project deploy start`.
