# Go-Live & Publish — reference (why each publish path works or fails)

Captured from a live build (Williams-Sonoma "AI Sous Chef" carousel → agent
`ShopperDemo9_30`, org `personaTestingDemo` = a storm/demo org) on 2026-09-30.
The build finished the carousel and deployed all metadata, then spent hours stuck
on `sf agent publish authoring-bundle`. It finally went live through the
Agentforce Builder **code view**, not the CLI. This file exists so a future run
picks the working path first instead of repeating the dead ends.

---

## TL;DR — the decision to make at go-live

1. Deploy all the metadata normally (Apex, Lightning Type, LWC, invocable action,
   CSP sites, permission set). This part never needed the publish API.
2. Try `sf agent publish authoring-bundle`. **If it returns `AgentApiNotFound`
   / `ERROR_HTTP_404`, stop retrying.** That endpoint is an external API the
   org may not be entitled for; more login attempts will not fix a 404.
3. Pivot to the **UI code-view path** (below). It works on any org that can open
   Agentforce Builder, needs no SFAP entitlement, and is what actually shipped
   this build. On a demo/scratch/storm org, consider it the default, not the
   fallback.

---

## The publish paths, and when each works

### Path A — CLI `sf agent publish authoring-bundle` (the one SKILL.md documents)

**What it actually does:** it does **not** talk to your org's SOAP/REST metadata
API. It calls an **external** Salesforce API:
`https://api.salesforce.com/einstein/ai-agent/v1.1/authoring/agents`
(with endpoint-prefix fallbacks `''`, `test.`, `dev.`). To do that the CLI
upgrades its connection to a NamedUser JWT and needs OAuth scopes `sfap_api`
(Access the Salesforce API Platform), `chatbot_api` (Access chatbot services),
and `web`.

**Works when:** the org is provisioned/entitled for the SFAP Agent **authoring**
API *and* the CLI's connected app carries those scopes. Production orgs with the
Agentforce/Einstein platform enabled.

**Fails on:** many demo/storm/scratch orgs. Signature of the entitlement wall:

```
name: AgentApiNotFound
message: Unable to access the Salesforce Agent APIs. Ensure the user '<user>' has the necessary permissions and authorization to perform this action.
cause: ERROR_HTTP_404   (data.message is empty)
```

A clean 404 with an **empty** message = the gateway is hiding a resource you
can't reach. That is either (a) the org isn't entitled, or (b) the token lacks
`sfap_api` (the SFAP gateway returns **404, not 403**, for unscoped resources).
You cannot tell (a) from (b) at the CLI, and you can't fix (a) yourself.

### Path B — Agentforce Builder **code view** (Agent Script) — the reliable path

This is what shipped the build. It uses the org's own Builder save/activate, no
external SFAP call.

1. Setup → **Agentforce Studio / Agents** →
   `/lightning/setup/EinsteinCopilot/home` → **New Agent**.
2. Pick a base template (**Agentforce Employee Agent** is a clean, Preview-
   testable base). Give it the label/API name. It drops you straight into the
   graph builder as `<Name> Version 1 (Draft)` — a real agent already in the org.
3. Open the **`</>` code view** (top-right toolbar). It shows the agent's full
   Agent Script and is **editable**.
4. Make a **surgical** edit — do not paste your standalone `.agent` wholesale
   (see "Surgical, not wholesale" below). Add to the template's own script:
   - one router route: `go_to_<x>: @utils.transition to @subagent.<x>` inside
     `start_agent … reasoning.actions`,
   - one `subagent <x>:` block with a `reasoning.actions` binding and an
     `actions:` block whose action uses `target: "apex://<InvocableClass>"` and
     the displayable output (`complex_data_type_name: "c__<LightningTypeFolder>"`,
     `is_displayable: True`, `filter_from_agent: False`).
5. **Save.** This validates server-side. A clean save means the org accepted the
   apex action target *and* the custom Lightning Type output — the same render
   contract the CLI bundle uses.
6. **Activate.** (Employee-agent activate did **not** prompt for a running user
   in this build; it just went live. If yours does, set the agent/running user.)
7. **Preview** → send the test prompt → confirm the card renders.

### Path C — classic GenAiPlanner + Bot metadata (older orgs / no Agent Script)

If the org's Builder has no code view and no "subagents" (see detection below),
it's the older model. Build the agent as `GenAiPlanner` + `GenAiPlugin`/
`GenAiFunction` + `Bot` metadata and deploy that directly — no external API.
This build didn't need Path C, but keep it as the option for pre-Agent-Script
orgs. (Not yet exercised end-to-end here; flag as the next thing to document.)

---

## Detect which Agentforce Builder the org has (drives A/B/C)

**New builder (Agent Script) — use Path B:**
- New Agent lands on a **graph canvas** with an **Agent Router / Start Agent** and
  **subagent** nodes.
- A **`</>` code view** shows an Agent Script (`system:` / `config:` /
  `start_agent … :` / `subagent … :`).
- `config.agent_template` looks like `EmployeeCopilot__AgentforceEmployeeAgent`;
  `agent_type: "AgentforceEmployeeAgent"`.

**Old builder — use Path C:**
- Agent is a list of **Topics** and **Actions**, no graph, no Agent Script code
  view, planner-based (`GenAiPlanner`).

Quick tell without clicking around: if `sf agent generate authoring-bundle` and
the `.agent` grammar are available in the org's CLI/Builder, it's the new model.

---

## What did NOT work — time sinks to skip next time

- **Building a custom connected app + re-login to add `sfap_api`/`chatbot_api`.**
  We created `ShopperDemo_SFAP_CLI`, added the UI-only scopes, and re-authed. The
  JWT upgrade then **succeeded** — and publish still returned the same clean 404.
  Net: fixing auth does not fix an unentitled org. Don't invest here until you've
  independently confirmed the org is SFAP-entitled. `sfap_api` and `chatbot_api`
  are **not valid `ConnectedAppOauthAccessScope` metadata enum values** — they can
  only be added in the App Manager UI, so this path also can't be fully scripted.
- **Reading the "expired access/refresh token" error as the real blocker.** That
  was a red herring — the interactive login token had simply aged out during
  hours of debugging. A fresh `sf org login web` cleared it and revealed the real,
  stable answer underneath: the 404. Re-login only if you see a refresh/expired
  token error; it will not clear a 404.
- **Querying `BotDefinition` via the Tooling API** to check whether Agentforce is
  on → "not supported". It's queryable via the **Data API**, not Tooling. Don't
  conclude "Agentforce is disabled" from a failed Tooling query.
- **Trusting the MCP read-only Salesforce connector to reflect the deploy target.**
  It pointed at a *different* org (org62) than the CLI target (the storm org). The
  "50 agents exist" evidence came from the wrong org. Always confirm org identity
  (`sf org display --verbose` → `instanceUrl`, `username`, `clientId`) before
  reasoning about entitlement.

## What DID work — the winning sequence

- Deploy every piece of metadata with a **single transactional deploy of the full
  scope** (see transactional note below), confirm all components committed.
- Create the agent from the **Employee Agent** template in Agentforce Builder.
- **Surgically** edit the template's own Agent Script in the code view to add the
  shopping subagent + one router route + the `apex://` action with the
  `c__` Lightning Type output. **Save** (clean). **Activate** (no prompts).
- **Preview** the test prompt → carousel rendered. Total UI time: a few minutes.

---

## Facts worth not re-learning

- **Salesforce deploys are transactional.** One failed component rolls back the
  whole deploy. Earlier this build, a publish error "Invocable action
  `RetailShoppingCarouselService` does not exist" was misleading — the classes had
  never committed, because 2 CSP errors in the same deploy rolled back all 9
  components. Fix the errors, redeploy the whole scope, confirm the count.
- **`default_agent_user` must be a real, active username** or publish/activate
  fails ("default agent user NEW AGENT USER not found"). Set it to a real user
  before going live.
- **Surgical, not wholesale, in the code view.** The template's script carries
  scaffolding your standalone `.agent` lacks — `agent_template`, the `current*`
  mutable context variables, the `knowledge:` block, `model_config`. Replacing the
  whole script risks dropping those and breaking the save or the agent type. Keep
  the template body; add only your route line + subagent + action block. Match the
  template's own grammar (e.g. it quotes input/output names: `"category": string`).
- **The render contract is identical across CLI bundle and code view.** The exact
  `apex://` target + `complex_data_type_name: "c__<Folder>"` + `is_displayable`
  that failure-mode #7 describes is what the code-view save validated. If Path B
  saves clean, your Lightning Type wiring is correct.
- **Employee-agent activate may not ask for a running user.** Preview still worked.
  Don't block on a running-user prompt that never appears.

---

## Implication for this skill's go-live check-in (Check-in 4)

Go-live must not assume `sf agent publish authoring-bundle` succeeds. On demo/
storm/scratch orgs it commonly 404s. Check-in 4 should:

1. Keep the normal metadata deploy (transactional, full scope, confirm counts).
2. Attempt CLI publish, but treat `AgentApiNotFound` / `ERROR_HTTP_404` as a
   **known org-entitlement wall**, not an auth bug — do not loop on re-login or
   connected-app scope fixes.
3. On that 404, detect the Builder generation and switch to **Path B** (new) or
   **Path C** (old), presenting the code-view paste as a first-class go-live path.
4. Only claim completion after a Preview/deployed-surface test renders the card.
