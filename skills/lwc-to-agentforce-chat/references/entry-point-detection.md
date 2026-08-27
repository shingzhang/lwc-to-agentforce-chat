# Entry Point Detection — reference

When **Entry 4** fires (the user doesn't know where to start), the skill scans the project folder and recommends one of Entries 1–3. This file is the algorithm.

The scan is read-only. It never writes files, never runs `sf` against an org, never mutates anything. Results are used to route the user to the right entry-point walk, not to auto-start it.

## Scan targets

| Signal | Command | What it means | Recommended entry point |
|---|---|---|---|
| Figma export files (`*.fig`, `.figma/` dir, PNG/JPG in `exports/`, `design/`, or `mockups/`) | `find . -maxdepth 4 -type f \( -iname '*.fig' -o -iname '*.png' -o -iname '*.jpg' \) \( -path '*design*' -o -path '*mockup*' -o -path '*export*' \)` | User has visuals, no code | **Entry 1 (Figma)** |
| Standalone HTML files (`*.html` at root or in `prototype/`, `mockups/`, `demo/`, but NOT inside `node_modules/` or `dist/`) | `find . -maxdepth 3 -type f -iname '*.html' -not -path '*/node_modules/*' -not -path '*/dist/*'` | User has HTML markup | **Entry 2 (HTML)** |
| Existing LWC bundle (a dir under `force-app/main/default/lwc/*/` with a `.js-meta.xml`) | `find force-app/main/default/lwc -maxdepth 2 -name '*.js-meta.xml' 2>/dev/null` | LWC exists | **Entry 3 (Existing LWC)** |
| Existing DTO (Apex class with `@JsonAccess(serializable='always'` in the body) | `grep -rIl "@JsonAccess(serializable='always'" force-app/main/default/classes/ 2>/dev/null` | DTO scaffolded but maybe incomplete | **Entry 3** (partial retrofit — fill in the missing pieces of the 5-piece contract) |
| Existing LightningTypeBundle (a `schema.json` under `force-app/main/default/lightningTypes/`) | `find force-app/main/default/lightningTypes -maxdepth 3 -name schema.json 2>/dev/null` | Type scaffolded | **Entry 3** |
| Existing agent bundle (a `.agent` file under `force-app/main/default/aiAuthoringBundles/`) | `find force-app/main/default/aiAuthoringBundles -maxdepth 3 -name '*.agent' 2>/dev/null` | Agent Script exists | **Entry 3** |
| `sfdx-project.json` present, everything else empty | `test -f sfdx-project.json` | Fresh SFDX project | Ask user what they want to bring in |

Run these in the order above and collect all matching signals before deciding — a project can trip multiple rows. Use the priority table below to resolve ties.

## Decision rules — the priority table

When multiple signals fire, apply this priority (first match wins):

1. **Existing LWC bundle** → **Entry 3.** Retrofit takes priority over anything else — the LWC is the biggest artifact, and rebuilding it from source loses whatever visual polish it already has. If Figma/HTML sources also exist, note them but recommend Entry 3 first.
2. **HTML file present + no LWC** → **Entry 2.** Source→LWC path. Faster than starting from a Figma when the HTML is already close to done.
3. **Figma-shaped assets + no LWC + no HTML** → **Entry 1.** Starting from design.
4. **Nothing found** → prompt user to describe what they want to bring in. Do not guess.

The priority reflects a "least work to a working chat card" heuristic — an existing LWC is closer to done than an HTML file, which is closer than a Figma frame.

## Emit — the inventory shape

When the scan completes, emit this exact shape:

```
Scanning `<absolute-path>`...

Found:
  • sfdx-project.json (project root confirmed)
  • force-app/main/default/lwc/retailPersonalizedPicks/ — 1 LWC bundle
  • force-app/main/default/classes/RetailProductPicksData.cls — 1 Apex DTO
  • No LightningType bundle
  • No Invocable Apex service
  • No Agent Script bundle

Recommendation: **Entry 3 — Existing LWC → chat wiring**
  You have Pieces 1 and 3 of the 5-piece contract. We'll add Pieces 2, 4, 5
  directly (partial retrofit).

Alternatives:
  • Entry 2 — if you want to rebuild the LWC from an HTML source instead
  • Entry 1 — if you want to redesign from a Figma before touching the LWC

Reply 3 to proceed with the recommendation, or 1/2/4 for an alternative.
```

Rules for the emit:
- Absolute path first, in backticks, so the user can verify what got scanned.
- Bulleted `Found:` list — one line per signal. Show "No X" rows for the missing pieces of the 5-piece contract, so the user sees the gap.
- One bold **Recommendation** line + one prose sentence explaining *why*.
- Two alternative bullets (skip if only one entry point is plausible).
- Numeric reply prompt at the end so the user can just type a digit.

## State table shape

When the scan (or a retrofit build) detects any pieces of the 5-piece contract, print a state table with one row per piece and a ✓/⚠/✗ status:

```
| Piece | Status | Notes |
|---|---|---|
| 1. Apex DTO | ✓ | RetailProductPicksData.cls found |
| 2. LightningType bundle | ✗ | not found |
| 3. LWC bundle | ✓ | retailPersonalizedPicks/ found |
| 4. Invocable Apex service | ✗ | not found |
| 5. Agent Script (.agent) | ⚠ | found, missing is_displayable |
```

✓ = present and looks complete. ⚠ = present but incomplete (e.g., `.agent` action exists but is missing `is_displayable`). ✗ = not found.

## Org-side inventory (once a target org is set)

The scan above is local-only — files on disk. When the user has a target org and wants to know what's already deployed, run these read-only queries and diff the result against the local scan:

```bash
sf data query --query "SELECT Id, DeveloperName, MasterLabel FROM BotDefinition" --target-org <alias>
sf data query --query "SELECT Id, DeveloperName, RoutingType FROM MessagingChannel" --target-org <alias>
sf data query --query "SELECT Id, DeveloperName FROM LightningTypeBundleInfo" --target-org <alias>
sf data query --query "SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = '<PermSetName>'" --target-org <alias>
```

A piece can be ✓ locally and ✗ in the org — written but not deployed. Call that out explicitly in the state table rather than collapsing it into a single status.

## Corner cases

- **Multiple LWCs found** → ask the user which one to focus on, listing all candidates with their `masterLabel` from `.js-meta.xml`. Or offer to run the scan per-LWC in a loop.
- **LWC found but no `sfdx-project.json`** → not an SFDX project; the skill can't run. Print an explanation ("An LWC bundle needs to live under `force-app/main/default/lwc/` in an SFDX project; I don't see `sfdx-project.json` at the project root. Point me at the project root or create one.") and stop.
- **Path passed by user is a subdirectory** → walk up until `sfdx-project.json` is found (max 3 parent levels). If not found, ask.
- **User in home dir or system dir** (`/`, `/Users/<name>`, `/etc`, `/tmp`, `/var`) → refuse. The scan globs recursively and could match unrelated PNGs or HTML files across the whole filesystem. Say so and ask for a specific project path.
- **`force-app/` exists but is empty** → treat as "fresh SFDX project" row above; recommend the user pick Entry 1 or 2 based on what they want to bring in.
- **`.mcp.json` present at project root** → not part of the entry-point decision, but the Figma-extraction reference will consume this signal at Entry 1 Step 3.
