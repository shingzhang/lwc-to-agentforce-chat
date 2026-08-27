# Contributing — lwc-to-agentforce-chat

These principles govern how contributors add skills, agents, hooks, and reference material. The plugin is a thin, opinionated wrapper around a larger Salesforce workflow, so its value depends on disciplined scope.

## Guiding principles

**1. Keep the plugin self-contained.** Everything the skill needs to teach — the 5-piece contract templates, the failure-mode fixes, the deploy sequence — lives inside this plugin's `SKILL.md` and `references/`. A reviewer who clones this repo with nothing else installed should be able to follow it start to finish without hitting a dead citation. If a related Salesforce skill exists elsewhere and covers similar ground in more depth, that's fine — just don't make this plugin's core walkthrough depend on it being present.

**2. One flow, one lane.** The skill has exactly one path: Figma → HTML preview → LWC bundle → 5-piece contract → deploy. Do not reintroduce alternate entry points (HTML-only, retrofit-existing-LWC, scan-my-folder). The v0.2 multi-entry version is preserved as a sibling directory for reference. If a new capability feels like a second flow, it belongs in a separate plugin. Lane confusion is how a skill becomes a 3920-line mega-file. Keeping the flow linear is how it stays reviewable.

**3. Teach, don't preach.** Every substantive action produces a `What / Why / Next` block, grounded in a concrete failure mode. Never write generic advice. If you can't cite `Failure Mode #N` from `references/failure-mode-crosswalk.md` or a specific LWC-platform constraint (shadow DOM boundary, `@api` reactivity, targetConfig binding), the "Why" line is wrong — rewrite it or drop the block. Users learn from watching real breakage get avoided, not from abstract principles.

**4. Load-bearing checkpoints are non-negotiable.** Writes to `force-app/`, `sf project deploy` (any variant), `sf agent validate/publish/activate`, and permset assignments all require explicit YES every time. `LWC_BUILD_STATE.md` is a live state canvas. The skill updates it automatically after every substantive turn (that is the point of the canvas). The one case that requires YES is overwriting user hand-edits made between turns. Read the file before writing, preserve user edits, ask on conflict. If a contributor adds a new deploy or write path that skips a checkpoint, the PR is invalid, no matter how clever the automation. This plugin's contract with the user is that it never deploys autonomously. Break that once and the trust is gone.

**5. Fictional customers, real patterns.** Any brand data that ships in fixtures or reference examples must be fictional (e.g., "Clover Clinic" or a made-up name of your choice). Never ship a real customer name, URL, org ID, or brand token in fixtures — not even one you have permission to use, because permissions change and public repos are forever. But the patterns underneath (5-piece contract, failure modes, deploy sequence) are real — they graduate from actual customer engagements. Fictionalize the shell, keep the guts honest.

**6. Experimental by default.** This plugin ships `experimental: true` in the skill's frontmatter until it has 3+ field engagements without a blocker. Contributors add scars — real failure modes we encountered — directly to `references/failure-mode-crosswalk.md` as they hit them, numbered and written up in full (symptom, cause, fix, verify). When we drop `experimental`, it's because the field has beaten on this, not because we feel ready.

## When Claude edits inside this plugin

- **Before adding a new skill** — search `forcedotcom/sf-skills` and `~/.claude/skills/` for overlap. If a skill covers 70%+ of the intended scope, propose a reference instead of a new skill.
- **Before adding a new agent** — ask: does this genuinely need context isolation? If not, use a Skill instead. Agents add complexity and a locked tool list; only reach for one when raw payloads would otherwise bloat the parent conversation.
- **Before adding a new hook** — ask: is this enforcement (block writes) or telemetry? Pure telemetry needs a strong justification for a v0.1 plugin. Hooks are load-bearing infrastructure, not decoration.
- **Before adding an MCP config** — check that the MCP server exists and is publicly accessible. Don't ship a `.mcp.json` referencing an internal-only server that a reviewer on a fresh clone can't reach.
- **When editing SKILL.md** — read `references/teaching-blocks.md` first. Every new step needs a `What / Why / Next` block. Every new question needs a `Step N of ~M` label. No exceptions, no shortcuts, no "I'll add it in the next PR."

## Version bumps

Semver, but with a plugin-specific rule: `metadata.version` on individual skills MAY diverge from the plugin's `plugin.json` version. Skills evolve on their own cadence. See FDE's `designing-agentforce/persona` (skill v3.0.1 inside plugin v1.5.0) for precedent — a mature skill inside a still-evolving plugin is a normal state, not a bug.

## When in doubt

Ping `#experience-specialists` or `#builder-coe-agent-skills`. Don't fork the hell out of everything. Slow down to ship well.
