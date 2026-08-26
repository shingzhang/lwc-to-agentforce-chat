# Failure-Mode Crosswalk — reference

Fast lookup from a symptom the user reports (or a state this skill detects during scan) to the exact numbered Failure Mode in `experience-cloud-site-builder` §C. The v1 skill has 17 numbered failure modes plus a "bonus" entry; this file is the index into that catalog.

This skill **never restates the fix**. It cites the number, prints a one-line diagnosis, and offers `R=details on Failure Mode #N` so the user can jump to the authoritative §C entry. That keeps the teaching layer honest (v1 §C is canonical; drift is expensive) and keeps each teaching block short.

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

1. Load the corresponding §C entry from `~/.claude/skills/experience-cloud-site-builder/SKILL.md` (which symlinks to `~/Documents/claude/skills/LWC/SKILL.md`).
2. Print the §C entry **verbatim**. Do not summarize. The v1 §C entries include precise retry counts, timing constants, SOQL verification queries, and Debug Log (DL-XX) references that are cite-worthy.
3. Print a return prompt: "Reply with the next step number, or paste new state to continue."

If the user types `R` and no FM has been cited in the immediately preceding message:

> Nothing cited yet. I'll surface `R` inline whenever I reference a specific Failure Mode.

Never load §C proactively — it's ~800 lines. Load on demand only.

## Cross-references

- **REQUIRED:** `experience-cloud-site-builder` §C — the authoritative source for every failure mode's full fix. This file is an index only.
- **REQUIRED:** `experience-cloud-site-builder` §C Debug Log (DL-01 through DL-13) — the historical debug-log entries that accompany the failure modes and give context (retracted hypotheses, timing traces, real Gack IDs seen in the field).
- **RECOMMENDED:** `building-agentforce-clt-widget` — its Step 1 state detection algorithm doubles as a first-pass check for FM #7, #9, #12, #13 when Entry 3 fires.
