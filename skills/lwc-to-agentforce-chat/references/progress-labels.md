# Progress labels

The workflow counts **interaction points**, not internal build actions. A user-facing
question uses `Check-in N of ~5 — <topic>`. The tilde allows a small clarification or
review loop without pretending the count is exact. Lead every substantive response with
a one-line progress marker so a checkpoint pause never reads as lost state.

## The ~5 check-ins (the only things that need the user)

- Check-in 1: confirm the design source, then the extracted Brand Summary read
- Check-in 2: review the HTML preview — in the same turn, confirm the API names
  (including the **agent name**) and provide + validate the real product image URLs
- Check-in 3: approve the real scoped deploy
- Check-in 4: approve go-live (CLI publish/activate/assign, or the Builder code-view path)
- Check-in 5: confirm the card rendered in the deployed surface

If the design source arrives in the opening request, Check-in 1 collapses to just
confirming the Brand Summary. If Check-in 2 needs edits (visual or image swaps), stay on
Check-in 2 — do not advance the count.

## Internal build phases (report as "done" notes, not as check-ins)

Between Check-in 2 and Check-in 3, all of this is you working — surface it as a running
sub-checklist, never as numbered steps that imply the user's turn:

HTML→LWC transform · Apex DTO · Lightning Type bundle · final LWC bundle · Invocable
Apex service · GenAI Function · generated AiAuthoringBundle + Agent Script edit ·
permission set + conditional trusted-site metadata · validate + dry-run.

There is no letter-command footer. If the user asks for status, show the state. If the
user asks for documentation, produce it as a normal, labeled follow-up.

## Rules

- Put the `Check-in N of ~5` label on every question, including approval checkpoints.
- Use a separate question and approval for the real deploy, then for go-live
  (publish/activate + permission assignment shown together).
- Never reuse a previous `YES`.
- If the work genuinely grows a new interaction point, say the estimate changed.
- Do not add an option before it can be performed.

Example:

```text
Build phase — GenAI Function metadata and both schemas written.

What: Registered the Apex invocation and described the custom object output.
Why: Agent Script's action target and the GenAI Function developer name must resolve together.
Next: finishing the authoring bundle, then Check-in 3 (approve the real deploy).
```
