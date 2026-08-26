# Contributing — lwc-to-agentforce-chat

These principles govern how contributors add skills, agents, hooks, and reference material. The plugin is a thin, opinionated wrapper around a larger Salesforce workflow, so its value depends on disciplined scope.

## Guiding principles

**1. Defer, don't duplicate.** Never restate content that already lives in `experience-cloud-site-builder`, `building-agentforce-clt-widget`, `generating-lwc-components`, or `applying-slds`. Reference by name with `**REQUIRED:**` / `**RECOMMENDED:**` markers. If you find yourself writing more than 20 lines about the 5-piece contract, stop — that's Phase 2 in `experience-cloud-site-builder`, and duplicating it here creates a fork that will drift within one release cycle. The whole point of this plugin is compression: four entry points, one shared tail, everything else referenced.

**2. One entry point, one lane.** Each entry point (Figma / HTML / existing LWC / scan folder) has its own §B Phase Playbook. Don't cross the streams. If a step feels like it should apply to two entry points, factor it into the shared tail (Phase 5) instead of duplicating it across two playbooks. Lane confusion is how a skill becomes a 3920-line mega-file; keeping the phases surgically separate is how it stays reviewable.

**3. Teach, don't preach.** Every substantive action produces a `What / Why / Next` block, grounded in a concrete failure mode. Never write generic advice. If you can't cite `Failure Mode #N` from `experience-cloud-site-builder` §C or a specific LWC-platform constraint (shadow DOM boundary, `@api` reactivity, targetConfig binding), the "Why" line is wrong — rewrite it or drop the block. Users learn from watching real breakage get avoided, not from abstract principles.

**4. Load-bearing checkpoints are non-negotiable.** Writes to `force-app/`, `sf project deploy` (any variant), `sf agent validate/publish/activate`, permset assignments, and overwrites of `LWC_BUILD_STATE.md` all require explicit YES. Every time. No exceptions. If a contributor adds a new write path that skips a checkpoint, the PR is invalid — no matter how clever the automation. This plugin's contract with the user is that it never deploys autonomously; break that once and the trust is gone.

**5. Fictional customers, real patterns.** Any brand data that ships in fixtures or reference examples must be fictional (e.g., "Clover Clinic" or a made-up name of your choice). Never ship a real customer name, URL, org ID, or brand token in fixtures — not even one you have permission to use, because permissions change and public repos are forever. But the patterns underneath (5-piece contract, failure modes, deploy sequence) are real — they graduate from actual customer engagements. Fictionalize the shell, keep the guts honest.

**6. Experimental by default.** This plugin ships `experimental: true` in the skill's frontmatter until it has 3+ field engagements without a blocker. Contributors add scars — real failure modes we encountered — to `references/failure-mode-crosswalk.md` as they hit them, cross-linked back to the `experience-cloud-site-builder` §C entry. When we drop `experimental`, it's because the field has beaten on this, not because we feel ready.

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
