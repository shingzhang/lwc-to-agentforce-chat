# Changelog

## 0.7.0 — 2026-09-30

- Reframed the workflow around **~5 check-ins** (interaction points) instead of
  13 numbered internal steps. A check-in exists only when the user must decide or
  look at something; all file generation, scaffolding, and validation happen under
  one "Build phase" banner reported as a running sub-checklist. Every response
  leads with a progress marker so a checkpoint pause never reads as lost state.
- **Image handling moved into the preview (Check-in 2).** Real product image URLs
  are collected and validated at preview time — the user sees them render before
  any metadata is wired. Each external host is recorded there and drives the later
  `CspTrustedSite` generation.
- **New preview-time hook** `hooks/verify-preview-images.sh`: blocks writing a
  `*.preview.html` when any embedded `http(s)` image URL returns 4xx/5xx, so a
  broken or hotlink-blocked image is caught immediately. Complements the existing
  deploy-time `verify-image-urls.sh`.
- **The agent name is now asked at the naming step**, not silently defaulted. The
  literal string is kept as the label; the API name is sanitized (hyphens →
  underscores).
- **Go-live branches** (Check-in 4): try CLI publish (Path A), but treat
  `AgentApiNotFound` / `ERROR_HTTP_404` as a known org-entitlement wall — not an
  auth bug — and pivot to the Agentforce Builder **code-view** path (Path B, with
  click-by-click steps) or the classic GenAiPlanner/Bot path (Path C). On
  demo/storm/scratch orgs the code-view path is preferred outright. Full rationale
  in `references/go-live-and-publish.md`.
- No change to the metadata render contract.

## 0.6.0 — 2026-09-29

- Fewer checkpoints. The workflow now moves through design extraction, the
  HTML preview, and all local Salesforce source writes autonomously, stating
  the assumptions it made instead of asking to write each file.
- Reduced the mandatory human checkpoints to three: the Step 3 visual review
  of the rendered HTML, the real org deploy, and a single consolidated
  publish + activate + assign confirmation. Validation and dry-run now run on
  their own since they do not mutate the org.
- Figma extraction runs without an approval gate; WebFetch proceeds on a
  public URL the user supplied themselves.
- No change to the metadata contract or the CLI lifecycle.

## 0.5.1 — 2026-09-29

- Reverted an accidental sync that had replaced the skill with a broader
  four-entry-point version (Figma / HTML prototype / existing LWC / folder).
  Restored the intended single-Figma-path flow: thirteen numbered steps, the
  mandatory HTML preview review, and the image-URL verification hook.
- No change to the metadata contract or the CLI lifecycle.

## 0.5.0 — 2026-08-27

- Replaced the legacy metadata templates with a reduced adaptation of
  Salesforce's current Custom Lightning Types recipe: Apex-bound
  `schema.json`, `$` renderer override, object output,
  `target: "apex://..."`, `filter_from_agent: False`, and GenAI Function
  metadata.
- The workflow now creates every artifact it deploys: a complete
  CLI-generated AiAuthoringBundle, GenAI Function schemas, a permission set,
  and conditional CSP metadata.
- Added an explicit `webfetch_approved` handoff. The extractor returns
  `WEBFETCH_APPROVAL_REQUIRED` instead of calling WebFetch without the
  parent's approval for that exact URL.
- Simplified progress to thirteen numbered steps, removed contradictory
  letter-option unlocks, restored the large-retailer persona, and removed
  local-only referrals.
- Embedded the stable fictional PNG fixture in the README and clarified that
  the hook protects Claude-initiated Bash deploys, not commands typed in
  another terminal.

## 0.4.3 — 2026-08-26

- Corrected fresh-clone marketplace instructions and aligned manifest versions.
- Added explicit agent triggering for the bundled fixture and a concise
  submission-readiness section.
- Tightened the build-your-own-plugin guide around one worked example.

## 0.4.2 — 2026-08-25

- Added the stable fictional 1200×620 retail PNG fixture and expected Brand
  Summary.
- Switched the Figma configuration to the official remote MCP endpoint.
- Removed retired multi-entry files and made the active workflow self-contained.
- Added strict validation and isolated-install smoke-test instructions.

## 0.4.0 — 2026-08-24

- Added the `figma-extractor` agent, Figma MCP configuration, and image-URL
  PreToolUse deploy guard.
- Reduced the plugin to one Figma-first flow with a mandatory HTML review.

## 0.1.0 — 2026-08-22

- Initial experimental plugin with a guided skill, extractor agent, hook, MCP
  configuration, README, and customer self-service guide.
