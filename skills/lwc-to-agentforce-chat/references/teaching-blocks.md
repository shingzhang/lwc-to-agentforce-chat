# Teaching Blocks — reference

The skill's core promise is *guiding + teaching* — not just producing output. Every substantive action the skill takes produces a compact three-line block that names What just happened, Why it mattered, and what comes Next. The reader learns the underlying LWC contract without having to ask a question or open a separate doc.

The Why is where the teaching lives. It grounds the current action in an actual constraint — shadow DOM, reactive `@api value`, targetConfigs binding, deploy-order — and cites a numbered Failure Mode when relevant (full write-up in `references/failure-mode-crosswalk.md`). That anchoring is what turns "the skill did a thing" into "I understand why the skill did that thing."

---

## The template — exact shape

```
✓ Step <N> of ~<M> — <what just happened, past tense, one line>.

  What: <one sentence, past tense, concrete>. Example: "Rewrote your <button onclick="handleClick()"> as <button onclick={handleClick}>."
  Why:  <one sentence, present tense, grounded in an LWC constraint or a v1 skill failure mode>. Example: "LWC compiles handler bindings as method references; parens would trigger eval at parse time."
  Next: <one sentence, future tense, tees up what's coming>. Example: "Step 5 — LWC needs an @api value getter/setter to receive data from the chat."

? · <footer of currently unlocked options>
```

Rules:

- Progress label uses `~` because M can drift ±2.
- **What** is past tense, one line, no more.
- **Why** is one sentence, present tense. Cites a failure mode by number when relevant (`Failure Mode #N` — full write-up in `references/failure-mode-crosswalk.md`).
- **Next** tees the next step.
- Footer is progressive-unlock — see `references/progress-labels.md`.

---

## When to emit a teaching block

Every time the skill:

- Writes a file
- Extracts a design token (color, typography, spacing, radius, shadow)
- Detects state (existing pieces of the 5-piece contract)
- Transforms HTML → LWC (any of the 8 transforms in `references/html-to-lwc-transforms.md`)
- Names an identifier (LWC bundle name, LightningType folder, DTO class, Invocable class, agent action)
- Reaches a load-bearing checkpoint (see main SKILL.md)
- Applies a Failure-Mode-preventing patch

**NOT** when the skill:

- Asks the user a question (progress label + question is enough)
- Prints a menu (Step 1 surface picker, sub-menus)
- Restates state at user request via `C=state` (just print the canvas)
- Prints the `?` verbose help output

---

## Canonical examples

Three examples covering steps not already shown in `SKILL.md` §C ("Three canonical examples" covers Step 2 extraction, Step 3 HTML preview, and Step 8 LWC bundle write). Copy the shape verbatim.

### Example 1 — HTML transform applied (Step 4, transform #1)

```
✓ Step 4 of ~11 — Rewrote 3 button handlers for LWC.

  What: Changed <button onclick="handleClick()"> → <button onclick={handleClick}> across 3 buttons in your approved shoppingCarousel.preview.html.
  Why:  LWC binds handlers as method references at compile time; parens would trigger eval at parse and fail the build. Failure Mode: compile-time error, easy to catch.
  Next: Step 5 — naming (prefix, LWC bundle, DTO class, LightningType folder).

? · C=state
```

### Example 2 — Piece 5 (`.agent`) written

```
✓ Step 10 of ~11 — Wrote Agent Script action for the carousel.

  What: Added `show_carousel` action to your .agent file with `is_displayable: True` and `complex_data_type_name: "c__Retail_Shopping_Carousel"`.
  Why:  These two lines are the whole difference between a chat that renders raw JSON and one that mounts your LWC. Failure Mode #7 — "Card replaced by text" — is what happens without them.
  Next: Step 11 — Deploy checkpoint. I'll print the exact sequence for you to run.

Type R for details on Failure Mode #7.

? · C=state · V=verify org
```

### Example 3 — Deploy checkpoint (never runs autonomously)

```
✓ Step 11 of ~11 — Deploy sequence ready.

  What: All 5 pieces are written locally. Preview: 4 Apex files, 1 LWC bundle, 1 LightningType bundle, 1 agent bundle, 1 permission set.
  Why:  This skill never runs `sf project deploy start`. Deploy order matters (Apex first → LightningType + LWC together → PermSet → CspTrustedSite → agent validate/publish/activate → assign permset to bot user with --on-behalf-of). Running out of order breaks the deploy.
  Next: Type `sf project deploy start ...` (I'll print the full commands). Or type `E=export docs` to generate BUILD_PROCESS.md first.

? · C=state · V=verify org · E=export docs
```

---

## What NOT to write in teaching blocks

- No hype: "Great!" / "Perfect!" / "Absolutely" / "I'd love to help"
- No restatement of the plan the user just approved
- No listing of what you're about to do before doing it
- Never omit the `Step N of ~M` label
- Never write a paragraph — three lines, three fields, that's it
- Never skip the footer once options have unlocked
- Never invent a Failure Mode number — cite only real ones (1–17 + bonus), all catalogued in `references/failure-mode-crosswalk.md`
