# Before You Build a Claude Code Plugin, Build the Workflow

*Version 2 — a one-page guide for frontend developers*

A good plugin usually starts as a conversation you are tired of repeating—not as a plugin folder.

To see how, build something deliberately playful:

> Create a space-themed website prototype for configuring a peanut-butter-and-jelly sandwich. Put the options on the left and a visual preview on the right. Let the user choose the bread, jam, crust, and diagonal or vertical cut, and view the sandwich from different angles.

This sounds silly. Underneath the space theme, it is a real frontend problem: several controls update shared state, combinations need rules, the preview must stay synchronized, and the experience must work on different screens and for keyboard users.

## Step 1: Build it with Claude before you automate it

Give Claude the prompt and review version one. You will probably find decisions the prompt did not contain:

- Should the preview update immediately?
- Does changing the cut update every angle?
- What happens when the crust is removed?
- Which combinations are incompatible?
- Where does the preview move on a phone?
- Are the controls labeled for a screen reader?

Go back and forth until the prototype behaves the way you want. Tell Claude when it guesses incorrectly. Ask it to verify assets instead of inventing image URLs. The corrections are not wasted turns; they are the raw material for the reusable workflow.

## Step 2: Extract what the successful run taught you

When the prototype is working, ask:

> Review our run. List the repeated instructions, my corrections, the decisions you had to make, the edge cases we found, and the definition of done. Show me the list before updating or creating anything.

For the sandwich configurator, the lessons might be:

- Keep configuration in one state object.
- Render every preview angle from that same state.
- Define incompatible combinations instead of handling them ad hoc.
- Update the preview immediately after a selection.
- Use accessible controls and a responsive narrow-screen layout.
- Verify visual assets and their content; never invent URLs.

Review the list. Claude can learn the wrong lesson from a successful run. Correct it before saving anything.

## Step 3: Turn the pattern into a skill

Do not create a skill called “make a PB&J website.” That would memorize the example.

Ask Claude:

> Turn the approved lessons into a skill for building interactive product-configurator prototypes. The skill should collect the product, options, compatibility rules, preview states, viewing angles, visual theme, responsive behavior, and accessibility requirements. Include clear success and failure states.

The **skill** is the reusable playbook. It replaces the repeated prompts and corrections from the original conversation.

Now test it on something different, such as a custom sneaker configurator with colors, materials, sizes, availability rules, and viewing angles. If the skill works for both sandwiches and sneakers, you captured a frontend pattern rather than one page.

When it fails, repeat the loop: finish the run, extract the new lessons, review them, and fold them back into the skill.

## Step 4: Decide whether it needs a plugin

A skill may be enough. Package it as a **plugin** when teammates need an installable capability with additional parts:

- Add a **custom agent** when one focused job benefits from separate context—for example, scanning a large component library and returning the components the configurator should reuse.
- Add **MCP or REST** when Claude needs external context or actions—for example, retrieving the design and variables from Figma.
- Add a **hook** when an event must automatically trigger a check, block, record, or action—for example, running accessibility validation after component files change.

Every addition should solve a named problem. Reading files does not automatically require an agent. Pasted input may be enough without MCP. A hook is unnecessary if the workflow never reaches the event it guards.

The package might look like:

```text
product-configurator-plugin/
├── .claude-plugin/plugin.json
├── skills/product-configurator/SKILL.md
├── agents/component-library-scanner.md
├── .mcp.json
├── fixtures/pbj/                 # first example
├── fixtures/sneaker/             # proves it generalizes
└── README.md
```

## Step 5: Make another developer prove it works

From a fresh clone, run:

```bash
claude plugin validate .
claude --plugin-dir .
```

Follow the README literally. A new developer should understand who the plugin serves, run a fictional example without customer credentials, and recognize the expected result in under five minutes.

If success still depends on your memory, an undocumented correction, or a lucky conversation, the plugin is not finished.

## The rule to keep

Build the example. Learn through iteration. Save the reusable behavior as a skill. Package it as a plugin only when the complete capability is worth installing and sharing.
