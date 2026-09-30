# Plugin change requests — lwc-to-agentforce-chat

A running list of changes Shing wants folded into the plugin, captured during a
live build session (Williams-Sonoma "AI Sous Chef" carousel) on 2026-09-30.
Apply these to the skill — and decide the hook question — before the next release.

Status legend: 🔲 requested · 🟡 partially done · ✅ shipped

**Update 2026-09-30:** Items #1–#6 shipped in SKILL.md 0.7.0. The workflow now
counts **~5 check-ins** (interaction points) instead of 13 internal steps; image
collection + validation moved into the preview; the agent name is asked at the
naming step; the go-live step branches (CLI Path A → Builder code-view Path B →
classic Path C). A new preview-time hook (`hooks/verify-preview-images.sh`)
validates image URLs return 2xx before a `*.preview.html` is written. The
open-decision below is resolved: instructions for the reordering + check-in, a
hook for image validation.

---

## 1. Always check in on the HTML at the preview step ✅

**Want:** At the HTML-preview step, always stop and get my reaction to the
rendered result before doing anything else. This is the one front-half check-in
I care about — I want to see the visual and confirm or correct it.

**Current state (0.6.0):** Step 3 is already the single mandatory front-half
checkpoint (visual review of the rendered HTML). This request confirms that
behavior should stay and be explicit — do not let a future "fewer checkpoints"
pass remove or soften it.

**Why:** The visual is where I catch problems cheaply, before any Salesforce
source exists. Everything downstream depends on the design being right.

---

## 2. Move image handling INTO the preview step ✅

**Want:** Collect and validate the real product image URLs *at the HTML preview
step*, not later. During the preview I want to:
  - provide the actual image URLs (one at a time is fine),
  - see them render in the preview so I know they work, and
  - confirm the images before we generate any Salesforce metadata.

**Current state:** Image sourcing and the `CspTrustedSite` generation live near
the end (Step 12). Images are placeholders during the preview.

**Change:** Fold image-URL collection + live validation into the preview step.
Keep the downstream `CspTrustedSite` generation, but drive it from the hosts
gathered here (record each external host at preview time; emit the trusted-site
metadata later from that recorded list).

**Why:** I want to validate that the image will actually load and pin the real
URLs up front, rather than discovering a broken/hotlink-blocked image after all
the metadata is wired. Validating early de-risks the whole build.

**Notes from this session:** `assets.wsimgs.com` (Williams-Sonoma CDN) served
images fine into the local preview. Fastest capture path for the user: on a WS
product page, right-click the main image → "Copy Image Address."

---

## 3. Ask for the agent name before defaulting it ✅

**Want:** At the naming step (Step 5), explicitly ask me what to name the
**agent** (bundle API name + label) rather than silently defaulting it to
`RetailShoppingAgent`. In this session the agent name was defaulted without
asking, and I only got to rename it at deploy time.

**Current state:** Step 5 states all API names and proceeds with no gate
("State the API names you are using and proceed — no approval gate"). That is
the right default for the LWC/Apex/type names, but the *agent* name is the one
I most often want to set myself (it's the user-facing thing I'll look for in
Setup → Agents).

**Change:** Keep the no-gate autonomy for the derived technical names, but call
out the agent name as a quick question at the naming step — e.g. "I'll name the
agent `RetailShoppingAgent` / 'Retail Shopping Agent' unless you'd prefer
something else." Fold it into the same Step 3/5 checkpoint turn so it doesn't
add a separate stop.

**Also:** sanitize whatever name I give into a valid API name (alphanumeric +
underscores, no hyphens) for `developer_name`, and keep my literal string as the
display label. In this session "ShopperDemo9-30" became API `ShopperDemo9_30`
with label "ShopperDemo9-30".

**Why:** The agent is the artifact I go find and demo. Defaulting its name means
I have to catch it late and rename across the bundle folder, files, and config.

---

## 4. Always show which step we're on ✅

**Want:** In every substantive response, state the current step explicitly —
e.g. "Step 13 of 13 — publish/activate/assign." When a single step has multiple
internal actions or checkpoints (like Step 13: validate → deploy → go-live →
verify), show a short checklist of those sub-actions with ✅/⬜ so I can see
exactly where we are and what's left. Never leave me guessing whether progress
was lost across a pause or a checkpoint.

**Why:** During this build the two separate critical checkpoints inside Step 13
(real deploy, then go-live) made it look like the workflow had lost its place.
A persistent "Step N of 13 + sub-checklist" header removes that ambiguity — the
pause is a deliberate checkpoint, not lost state, and the header should make
that obvious.

**How to apply:** The skill already defines a teaching-block format
(`✓ Step N of ~13 — …`). Strengthen it so the step marker appears on *every*
response during the build, and expand it to a sub-checklist for multi-action
steps (esp. Step 13). Consider a running progress line in LWC_BUILD_STATE.md
that each turn updates and echoes.

---

## 5. "Steps" should mean interaction points, not internal actions ✅

**Want:** Stop numbering the workflow as ~13 steps that each look like they need
me. A "step" I'm shown should only exist when you have a question for me or need
me to check something. Everything else — writing files, scaffolding, validating,
transforming, deploying-as-dry-run — is just you working; do it under one banner
and don't present it as a step that implies my involvement. In this build I only
actually needed to weigh in ~5 times, so the workflow really has ~5 interaction
points, not 13.

**Why:** Labeling internal build actions "Step 6, Step 7, …" made it feel like a
long checklist I had to babysit, and made an ordinary checkpoint pause look like
lost state. If the visible steps map 1:1 to "Shing needs to do or decide
something," the count I see stays small and honest, and each one clearly means
"your turn."

**How to apply:** Re-frame the 13 as internal phases. Surface only the true
interaction points as the numbered/counted items — realistically:
  1. source + brand confirm,
  2. HTML preview review + names (incl. agent name),
  3. images validated,
  4. real deploy approval,
  5. go-live (publish/activate/assign),
  then the final "verify it renders."
Report internal work as brief "done" notes, not as steps awaiting me. This
supersedes the "Step N of 13" phrasing in item 4: keep the progress transparency,
but count only my touchpoints.

**Relationship to item 4:** Reframes it — still show where we are, but the
visible counter runs over *interaction points*, not internal build steps.

---

## 6. Branch the go-live step; the CLI publish is not the only (or reliable) path ✅

**Want:** Step 13 shouldn't assume `sf agent publish authoring-bundle` works. On
this build it never did — the org (a storm/demo org) returned a clean
`AgentApiNotFound` / `ERROR_HTTP_404` from the external SFAP API, and no amount
of re-login or connected-app scope fixing cleared it. We eventually went live
through the **Agentforce Builder code view**: create the agent from a template,
open `</>`, surgically add the shopping subagent + one router route + the
`apex://` action with the `c__` Lightning Type output, Save, Activate, Preview.
That path needs no SFAP entitlement and took minutes.

**Change:** Make Step 13 branch. Attempt CLI publish, but treat a 404 as a known
org-entitlement wall (not an auth bug — don't loop on re-login/scopes). Detect
the Builder generation (new Agent Script graph vs. old topic/planner) and present
the code-view paste (new) or GenAiPlanner/Bot metadata (old) as first-class
go-live paths. On demo/storm/scratch orgs, prefer the code-view path outright.

**Why:** Hours were lost treating a 404 as something the user could fix. All the
hard metadata (Apex, Lightning Type, LWC, invocable, CSP, permset) deploys via
normal transactional metadata; only "publish" needs the SFAP API, and the UI
code view bypasses it entirely.

**How to apply:** Captured in full in
`skills/lwc-to-agentforce-chat/references/go-live-and-publish.md` (paths A/B/C,
builder detection, the exact 404 signature, the dead ends to skip, and the facts
worth not re-learning: transactional rollback, `default_agent_user`, surgical-vs-
wholesale code edits, BotDefinition via Data API not Tooling, MCP-connector org
mismatch). SKILL.md Step 13 now points at it. Fold the branch into the prose and,
if useful, add FM entries for the 404 wall.

---

## Open decision: hook vs. instructions

Do items 1 and 2 belong in the **skill instructions** (SKILL.md prose) or in a
**hook**?

- Item 1 (mandatory visual check-in) reads as **instructions** — it's a
  conversational checkpoint, not a mechanical guard. Instructions are the
  natural fit; a hook can't force a human "does this look right?" pause.
- Item 2 (image URLs live in the preview step) is mostly **instructions** too
  (reorder the workflow). A **hook** could *complement* it by validating that
  each provided image URL returns a 2xx before the preview is considered
  approved — similar to the existing deploy-guard hook that checks image URLs
  in scoped Apex. Consider extending/relocating that check to preview time.

**Recommendation to revisit:** instructions for the reordering + check-in;
optionally a small PreToolUse/validation hook to verify image URLs resolve at
preview time so a broken URL is caught immediately.
