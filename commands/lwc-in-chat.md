---
description: Turn a Figma design into a Lightning Web Component that renders inside an Agentforce chat bubble. Guided walkthrough with a mandatory HTML preview step in the middle.
---

# /lwc-to-agentforce-chat:lwc-in-chat

Launches the `lwc-to-agentforce-chat` skill's Step 1 prompt — paste a Figma URL, PNG path, or MCP node ID. From there, the skill guides you one question at a time through: Figma extraction → HTML preview (mandatory review in a browser) → LWC transform → 5-piece contract → deploy checkpoint.

A shortcut exists alongside the natural-language auto-trigger because some users want an explicit entry. When installed as a plugin, invoke it as `/lwc-to-agentforce-chat:lwc-in-chat`.

## What happens when you invoke the shortcut

1. The `lwc-to-agentforce-chat` skill loads and prints the Step 1 prompt asking for a Figma source.
2. You paste a Figma URL, a local PNG/JPG path, or an MCP node ID (`file_key:node_id`).
3. Step 2 — the `figma-extractor` subagent extracts the Brand Summary and infers the visual pattern.
4. Step 3 — the skill writes `<component>.preview.html` and asks you to review it in a browser (`open <path>` on macOS). This step is non-skippable. If you request edits, it regenerates and re-previews.
5. Once you approve the HTML, Step 4 transforms it into an LWC bundle using the 8 transforms in `references/html-to-lwc-transforms.md`.
6. Steps 5–10 walk the 5-piece contract (Apex DTO, LightningType bundle, LWC bundle, Invocable Apex, Agent Script), one YES per piece.
7. Step 11 prints the deploy sequence — you run it explicitly, not the skill.

## Alternate invocation

The same skill also auto-triggers on natural language. Examples that route to this skill:

- "I have a Figma design I want in an Agentforce chat card"
- "Turn this Figma into an LWC that renders in chat"
- "How do I render this design inside an agent chat bubble"

If the skill doesn't auto-trigger reliably on your phrasing, the slash command is the fallback.

## Requirements

- Salesforce CLI (`sf`) v2+ installed and authenticated to a target org — required only for verify/deploy steps (which **you** run explicitly, not the skill).
- An SFDX project (`sfdx-project.json` present at the project root) — the skill offers to scaffold one if you don't have it.
- Optional: authenticate the bundled official Figma MCP server through `/mcp`. If it is unavailable, Step 2 falls back to WebFetch on a public Figma URL or reads a local PNG/JPG export.

## See also

- `skills/lwc-to-agentforce-chat/SKILL.md` — the full guided walkthrough this command invokes.
- `README.md` — plugin overview + fresh-clone install steps.
- `GUIDE.md` — build your own plugin around a different entry-point workflow.
