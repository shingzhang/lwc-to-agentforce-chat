# Before You Build a Claude Code Plugin, Build the Workflow

*A one-page guide for enterprise frontend developers*

A useful plugin usually starts as a conversation your team is tired of repeating. Prove the workflow with Claude first; package it only after you know where human judgment matters.

Use a deliberately playful first project:

> Create a space-themed website prototype for configuring a peanut-butter-and-jelly sandwich. Put controls on the left and a live preview on the right. Support bread, jam, crust, cut direction, viewing angles, mobile layouts, and keyboard users.

The theme is silly, but the work is recognizable: controls share state, combinations have rules, assets need verification, and the interface must remain responsive and accessible.

## 1. Complete one real run

Give Claude the prompt and review version one. Correct missing decisions: when the preview updates, which combinations are incompatible, how the layout collapses on a phone, and how a keyboard user operates it. Require Claude to verify assets instead of inventing URLs.

Keep iterating until the prototype behaves correctly. These corrections are not wasted turns; they are the raw material for the reusable workflow.

## 2. Extract the reusable judgment

Ask Claude:

> Review our run. List my repeated instructions, corrections, decisions, edge cases, and definition of done. Show me the list before creating or updating anything.

Review that list yourself. Claude can learn the wrong lesson from a successful result. For this example, the durable rules might be: keep configuration in one state object, render every angle from it, define incompatibilities explicitly, update immediately, preserve accessibility on narrow screens, and verify every visual asset.

## 3. Turn the pattern into a skill

Ask Claude to turn the approved rules into a skill for *interactive product configurators*, not a skill for making one PB&J page. The skill should collect the product, options, compatibility rules, preview states, theme, responsive behavior, accessibility requirements, and success and failure states.

Test it on a different example, such as a sneaker configurator. If it works for both sandwiches and sneakers, you captured a workflow rather than memorizing a demo. Fold any new corrections back into the skill.

## 4. Package only what the workflow needs

A skill may be enough. Build a plugin when teammates need an installable capability with additional parts:

- Add an **agent** when one focused job benefits from separate context, such as scanning a large component library and returning a compact shortlist.
- Add **MCP** when the workflow needs external context, such as Figma components and variables.
- Add a **hook** when an event must automatically check or block something, such as accessibility validation after component changes.

Every part should solve a named problem. A minimal package might be:

```text
product-configurator-plugin/
├── .claude-plugin/plugin.json
├── skills/product-configurator/SKILL.md
├── agents/component-library-scanner.md
├── fixtures/pbj/
├── fixtures/sneaker/
└── README.md
```

Give the manifest a unique kebab-case `name`. Give the skill and agent clear frontmatter that says when they should and should not run. Inspect every generated instruction; remove generic features you cannot connect to a real failure or user need.

## 5. Let another developer prove it

From a fresh clone, have a teammate run:

```bash
claude plugin validate .
claude --plugin-dir .
```

Then have them follow the README literally. It should name the persona and problem, explain installation, and provide a fictional example with a recognizable result in under five minutes and without customer credentials.

If success still depends on your memory, an undocumented correction, or a lucky conversation, the plugin is not finished.
