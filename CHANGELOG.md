# Changelog

All notable changes to `lwc-to-agentforce-chat` will be documented here. The format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.2.1] — 2026-08-25 · Submission hardening

### Changed

- Added a local marketplace manifest and corrected the fresh-clone install instructions.
- Replaced placeholder stdio MCP entries with Figma's official remote MCP endpoint.
- Allowed the read-only Figma agent to inherit MCP tools while continuing to deny `Write` and `Edit`.
- Added a no-org local preview mode for the reproducible HTML fixture.
- Made optional Salesforce skill integrations non-blocking on a fresh clone.
- Renamed root contributor guidance to `CONTRIBUTING.md` so plugin validation is warning-free.
- Replaced customer-shaped names and asset domains with fictional retail examples.

## [0.3.0] — 2026-08-25 · Single flow with mandatory HTML preview

### Changed

- **Reduced to a single, linear flow: Figma → HTML preview → LWC.** The four-entry-point picker is gone. There is one path: paste a Figma source, extract the Brand Summary, review an intermediary HTML file in your browser, then transform into an LWC bundle + 5-piece contract.
- **Step 3 (HTML preview) is non-skippable.** The skill writes `<component>.preview.html` and waits for an explicit YES (or an edit request) before transforming to LWC. Load-bearing checkpoint per CLAUDE.md principle #4. This is where the design-review moment lives — LWC has no mid-build browser preview, so the intermediary HTML is where you catch misread Figma tokens before the transform + write cycle.
- **`figma-extractor` agent** no longer says "Entry 1 only" — it's the only extraction path now. Trigger language updated to reference Step 2.
- **Slash command `/lwc-in-chat`** rewritten to describe the linear flow. The 1/2/3/4 picker language is gone.
- **README** rewritten: one-flow description, `v0.3.0` badge, "Try it in 30 seconds" now shows the single Figma → HTML preview → LWC path, `building-agentforce-clt-widget` optional-integration line removed (Entry 3 is gone), rubric row wording updated.
- **State canvas** adds an `## HTML Preview` section tracking preview path + approval status.

### Removed

- Entry point 2 (HTML → LWC as a standalone entry).
- Entry point 3 (existing LWC → chat wiring / retrofit).
- Entry point 4 (scan-my-folder → funnel).
- The `S=switch path` standing option (nothing to switch between when there's one path).
- The `references/entry-point-detection.md` file remains on disk but is unreferenced from `SKILL.md` — retained in case the multi-entry version is ever restored.

### Archived

- The full v0.2.2 multi-entry plugin is preserved at `~/Documents/claude/plugin homework/lwc-to-agentforce-chat-multi-entry/`. Not installed; reference-only. Restore by copying files back into the active plugin directory.

### Rationale

Shing wants to eyeball the HTML before it becomes LWC every time. The four-entry version treated HTML as one branch among four; this version bakes the HTML review into the middle of the only flow, where it can't be skipped.

## [0.2.2] — 2026-08-25 · Docs + MCP detection fix

### Fixed

- **MCP detection copy no longer misleads.** The skill previously said "No Figma MCP is configured in `~/.claude/settings.json`" when tools were unavailable in the session. That was misleading — the MCP is bundled and registered by the plugin's own `.mcp.json`; the real state is often "registered but not authenticated." Detection logic in `references/figma-extraction.md` and `SKILL.md` now leads with `mcp__figma__*` tool availability in the session and separately calls out registered-but-unauthenticated as a distinct troubleshooting state.
- **Editor-URL guidance added.** `figma.com/design/…?m=dev` (Figma editor URLs) are canvas SPAs. WebFetch only returns the login shell. The reference doc and SKILL.md now say so explicitly and route those URLs to Path A (MCP) or Path C (screenshot).

### Added

- **README `Set up Figma MCP` section** with prerequisites, auth flow, and how the walkthrough consumes the MCP.
- **README `Troubleshooting` section** covering the common failure modes: MCP not authenticated, WebFetch on editor URLs, moved plugin folder, LWC_BUILD_STATE.md prompt, load-bearing checkpoints, skill not triggering on a bare URL, `sf` CLI missing.

## [0.2.0] — 2026-08-25 · Figma-agnostic

### Changed

- **Removed the `fixtures/willas-corner-grocery-figma/` fixture.** Entry 1 now runs against a user-supplied Figma URL (public share link or MCP-accessible file). The plugin no longer bundles a canned Figma example — bring your own. `fixtures/example-html/` (Entry 2's HTML→LWC before/after sample) is preserved.
- **Reference example rewritten with placeholders.** `skills/lwc-to-agentforce-chat/assets/examples/figma-input.md` now uses `<placeholder>` brand tokens instead of a specific fictional brand, so the walkthrough reads cleanly against any Figma input.
- **README `Try it in 30 seconds` section updated** to reflect the two remaining try-flows (bring-your-own-Figma + bundled HTML fixture).

### Rationale

The bundled fixture was useful for out-of-the-box reproducibility, but the more common use case is running the plugin against a real Figma the developer already has. The Willa fixture is preserved in the sibling directory `lwc-to-agentforce-chat-willa/` (v0.1.0) for anyone who wants a canned reproducible example.

## [0.1.0] — 2026-08-25 · Initial

### Added

- **Skill: `lwc-to-agentforce-chat`** (v0.1.0, experimental) — guided-wizard skill with four entry points (Figma / HTML / existing LWC / scan folder), teaching-block output after every substantive action, progressive-unlock standing options (`C=state`, `S=switch path`, `V=verify org`, `E=export docs`, `R=details`), and load-bearing checkpoints for all file writes and deploys.
- **Agent: `figma-extractor`** — subagent for heavy Figma processing. Locked tool list (`Bash`, `Read`, `WebFetch`). Extracts Brand Summary + pattern inference from a Figma URL or PNG, returns structured JSON to the parent skill, avoids bloating the parent conversation with raw node-tree payloads.
- **MCP config: `.mcp.json`** — Figma MCP server template (two options: official `@figma/mcp-server` and community `figma-developer-mcp`). Both entries disabled by default; user renames to `figma` to enable. Skill falls back to WebFetch on public Figma URLs if no MCP is configured.
- **Slash command: `/lwc-in-chat`** — explicit invocation entry that maps directly to the skill's Step 1 surface picker.
- **Fixtures**: `fixtures/willas-corner-grocery-figma/` (fictional Figma-input scenario with expected extraction output) and `fixtures/example-html/` (before/after HTML→LWC transform sample). Both are fully fictional — no real customer names, URLs, or metadata.
- **Governance docs**: `CLAUDE.md` (contributor principles), `README.md` (install + demo in <5 min), `GUIDE.md` (one-page "build your own plugin for a different entry-point workflow").

### Known limitations

- Figma MCP detection is a config-file check (`.mcp.json` inspection). If a user has the MCP server available but not registered in `.mcp.json`, the skill won't pick it up.
- HTML→LWC transform v0.1 covers 8 rules. Handlebars/Mustache templating and dynamic `<script>` handling are outside scope for now — flagged as future work.
- Entry 3 retrofit delegates to `building-agentforce-clt-widget` for state detection. If that skill isn't installed, the retrofit path degrades to a manual walkthrough.
- Zero sandbox writes: this plugin never runs `sf project deploy start` autonomously. Load-bearing checkpoints require explicit YES before every write to `force-app/` and every `sf` deploy command.
