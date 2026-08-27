# Teaching blocks

After every substantive action, explain what changed, why the platform requires
it, and what the next numbered checkpoint is.

```text
✓ Step <N> of ~13 — <completed action>.

What: <one concrete sentence>.
Why: <one Salesforce or LWC constraint, or a failure prevented>.
Next: <the next numbered question>.
```

Keep the block to three short sentences. Do not add a standing-options footer.

## When to use one

- after extracting design tokens
- after writing the HTML preview
- after applying HTML-to-LWC transforms
- after writing each Salesforce metadata artifact
- after validation, dry-run, deploy, publish/activate, or permission assignment
- after applying a documented failure-mode fix

Do not emit one merely for asking a question or reprinting status.

## Examples

```text
✓ Step 4 of ~13 — Converted the approved product row into an LWC renderer.

What: Moved inline handlers and styles into scoped LWC files and added a reactive value setter.
Why: Agentforce supplies the action output after mount, so a one-time property read can render blank.
Next: Step 5 will lock the API names used by every metadata reference.
```

```text
✓ Step 11 of ~13 — Generated and completed the Agent Script authoring bundle.

What: Added an Apex-targeted action with an object carousel output and matching GenAI Function source.
Why: A snippet alone is not deployable, and the custom renderer requires the object output contract.
Next: Step 12 will create the bot user's least-privilege permission set.
```

```text
✓ Step 13 of ~13 — The scoped deployment dry-run passed.

What: Validated only the generated Apex, Lightning Type, LWC, GenAI Function, agent bundle, and permission set.
Why: A dry-run catches dependency and metadata errors before changing the org.
Next: Step 13 will ask separately whether to run the real scoped deploy.
```
