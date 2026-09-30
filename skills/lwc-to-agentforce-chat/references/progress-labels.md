# Progress labels

Every question uses `Step N of ~13 — <topic>`. The tilde allows a small
clarification or review loop without pretending the turn count is exact.

## Canonical map

- Step 1: design source
- Step 2: Brand Summary extraction and correction
- Step 3: mandatory HTML preview and review; repeat Step 3 for edits
- Step 4: HTML-to-LWC transform
- Step 5: API names
- Step 6: Apex DTO
- Step 7: Lightning Type bundle
- Step 8: final LWC renderer bundle
- Step 9: Invocable Apex service
- Step 10: GenAI Function
- Step 11: generated AiAuthoringBundle plus complete Agent Script
- Step 12: permission set and conditional trusted-site metadata
- Step 13: validate, dry-run, deploy, publish/activate, assign, and test

If the source arrives in the opening request, begin at Step 2 but keep the
canonical numbers. If Step 3 needs edits, do not increment the step.

There is no letter-command footer. If the user asks for status, show the state.
If the user asks for documentation, produce it as a normal, labeled follow-up.

## Rules

- Put the label on every question, including approval checkpoints.
- Use a separate question and approval for validation/dry-run, real deploy,
  publish/activate, and permission assignment.
- Never reuse a previous `YES`.
- If the workflow grows by three or more steps, say that the estimate changed.
- Do not add an option before it can be performed.

Example:

```text
✓ Step 10 of ~13 — Wrote the GenAI Function metadata and both schemas.

What: Registered the Apex invocation and described the custom object output.
Why: Agent Script's source and the GenAI Function developer name must resolve together.
Next: Step 11 will generate a complete authoring bundle before editing its action.

Step 11 of ~13 — Generate the authoring bundle with this command?
```
