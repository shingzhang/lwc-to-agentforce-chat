# Changelog

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
