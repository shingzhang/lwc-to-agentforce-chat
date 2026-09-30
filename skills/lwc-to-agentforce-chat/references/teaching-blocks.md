# Teaching blocks

After every substantive action, explain what changed, why the platform requires
it, and what comes next. Internal build work uses a `Build phase —` header; the
~5 interaction points use `✓ Check-in N of ~5 —`.

```text
✓ Check-in N of ~5 — <completed action>.   (or: Build phase — <sub-item> done.)

What: <one concrete sentence>.
Why: <one Salesforce or LWC constraint, or a failure prevented>.
Next: <the next check-in, or the remaining build sub-items>.
```

Keep the block to three short sentences. Do not add a standing-options footer.

## When to use one

- after extracting design tokens (Check-in 1)
- after writing or regenerating the HTML preview (Check-in 2)
- after applying HTML-to-LWC transforms and after writing each Salesforce
  metadata artifact (Build phase — sub-items)
- after validation, dry-run, deploy, publish/activate, or permission assignment
- after applying a documented failure-mode fix

Do not emit one merely for asking a question or reprinting status.

## Examples

```text
Build phase — converted the approved product row into an LWC renderer.

What: Moved inline handlers and styles into scoped LWC files and added a reactive value setter.
Why: Agentforce supplies the action output after mount, so a one-time property read can render blank.
Next: Apex DTO and Lightning Type bundle, then the invocable service.
```

```text
Build phase — generated and completed the Agent Script authoring bundle.

What: Added an Apex-targeted action with an object carousel output and matching GenAI Function source.
Why: A snippet alone is not deployable, and the custom renderer requires the object output contract.
Next: permission set + conditional CSP, then validate/dry-run → Check-in 3 (real deploy).
```

```text
✓ Check-in 3 of ~5 — the scoped deployment dry-run passed.

What: Validated only the generated Apex, Lightning Type, LWC, GenAI Function, agent bundle, and permission set.
Why: A dry-run catches dependency and metadata errors before changing the org.
Next: I'll ask for one YES to run the real scoped deploy.
```
