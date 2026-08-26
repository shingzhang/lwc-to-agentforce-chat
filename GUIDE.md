# Build a plugin from work your team already does

This guide is for a Salesforce front-end engineer who wants Claude Code to help with a different workflow—not the Figma-to-Agentforce workflow in this repo.

## Start by experimenting with Claude

You do not need to design a plugin before you know whether the workflow is useful. Start with an ordinary Claude Code conversation. For a low-stakes example, ask Claude to build a peanut-butter-and-jelly prototype. Go back and forth on the ingredients, order of operations, validation, and output until it behaves the way you want.

Now look at the conversation. Which instructions did you repeat? Which corrections changed the result? Which decisions would be the same next time? That is the beginning of a reusable workflow.

For real frontend work, the experiment might be turning Figma frames into accessible components, generating stories and tests for existing components, checking a pull request against your design system, migrating components after an SLDS change, or turning an API schema into a typed client.

## Choose a use case worth packaging

A strong first plugin serves one specific developer, begins with a recognizable input, and produces a result you can verify. It should contain either repeated judgment worth teaching Claude, access to a system Claude cannot otherwise inspect, or an important team rule worth enforcing.

Write one sentence: “For a **[specific developer]** who starts with **[artifact]**, produce **[destination]** while preventing **[costly failure]**.” If the sentence needs several users, inputs, or outcomes, narrow version one.

## Understand the difference between a skill and a plugin

A **skill** is the reusable recipe Claude follows: when to use it, what to inspect, which questions to ask, what rules matter, and what success looks like. It replaces the repeated prompts and corrections you discovered while experimenting.

A **plugin** is the installable package that delivers a complete capability. It can contain one or more skills plus agents, commands, MCP connections, hooks, and documentation. The skill teaches Claude how to do the workflow; the plugin bundles everything a teammate needs to install and use it.

An **agent** performs one meaningful, focused job with its own context—for example, inspecting a component library and returning an accessibility inventory. An **MCP server** gives Claude structured access to a system such as Figma or GitHub. A **hook** reacts to or enforces a local event, such as requiring validation before deployment.

The smallest useful shape is:

```text
your-plugin/
├── .claude-plugin/plugin.json
├── skills/your-workflow/SKILL.md
├── agents/source-analyzer.md
├── .mcp.json              # or hooks/hooks.json
├── fixtures/example/
└── README.md
```

## Build it with Claude Code

After the experiment works, ask Claude: “Review our conversation. Identify the repeatable inputs, decisions, corrections, tools, failure points, and definition of done. Turn that into a reusable skill so I do not need to prompt through the same process next time.” Correct its summary until the workflow sounds like something you could teach a new teammate.

Run the skill on a fresh example. When Claude chooses the wrong branch, asks an unnecessary question, or produces an unverifiable result, improve the skill—not just that output. Once the recipe is stable, ask Claude to package it as a plugin. Have it add a focused agent and an MCP server or hook only when they solve a specific need, then scaffold the structure above.

Finally, make the five-minute path real:

```bash
claude plugin validate .
claude --plugin-dir .
```

Verify the skill and agent load, the integration connects, the fixture produces the expected result, and the README works from a clean directory exactly as a teammate would follow it.

## Definition of done

You are done when the plugin solves one named developer’s problem, the agent performs meaningful work, the skill works without hidden context, the integration is necessary, the fixture proves the happy path, and a teammate can reach that proof from the README in under five minutes.
