# Progress Labels — reference

Every question the skill asks carries a `Step N of ~M — <topic>` label. The `~` (tilde) is deliberate. The count can shift ±2 based on answers without breaking the promise. This gives the user a clear sense of "how much longer" without lying about the exact endpoint.

The label appears above the question. The compact-update line and footer sit below it. See `teaching-blocks.md` for the What/Why/Next micro-block that runs after each substantive action.

## Step budget

~11 steps end-to-end. Range: 9–13. See `SKILL.md` §C for the canonical step map:

- Step 1: source
- Step 2: extract Brand Summary
- Step 3: HTML preview + review (may loop on edits)
- Step 4: transform to LWC bundle
- Step 5: naming
- Steps 6–10: 5-piece contract
- Step 11: deploy checkpoint

## When to update M mid-flow

The tilde is a promise, not a lie. Reasons M can shift:

- **Step 3 loop**: if the user asks for edits to the HTML preview, do not increment the step count. Step 3 can repeat several turns in a row before the user approves; M doesn't move.
- **Source material provided up front**: if the user pastes a Figma URL, local image path, or MCP node ID with their first message, the skill skips the opening prompt and starts at Step 2. M shrinks by 1.
- **Extraction runs thin**: an ambiguous Figma source or a low-confidence pattern match can add a clarifying question, +1 to M.

Rule: if the change is **±2**, keep the tilde and stay silent. If it's **±3 or more**, print an explicit `Step count updated: now ~N total` line before the next label.

## Footer format — progressive unlock

At Step 2 onward, print a footer showing currently-unlocked standing options. Short form only. Prefix with `?` so the user knows help is one keystroke away.

| Option | Unlocks when | Short-form footer |
|---|---|---|
| `C` — Show me what's been decided | After Step 2, once `LWC_BUILD_STATE.md` has been created | `C=state` |
| `V` — Verify what's in the org vs. what's local | After the first successful `sf project deploy` | `V=verify org` |
| `E` — Export handoff documentation | After Step 10 | `E=export docs` |
| `R` — Details on a cited rule / failure mode | Contextual only — surfaced inline when the skill just cited `Failure Mode #N` | inline: `Type R for details on Failure Mode #N` |

`R` never appears in the persistent footer. It only appears inline, and only when a Failure Mode number was cited in the previous turn.

## Example footer progression

- **Step 1**: no footer (nothing actionable yet)
- **Step 2 onward**: `? · C=state`
- **After first deploy**: `? · C=state · V=verify org`
- **After Step 10**: `? · C=state · V=verify org · E=export docs`

## Compact update lines

After every user answer, print one acknowledgement line, then the next question labeled with progress, then the currently-unlocked footer. Example (right after Step 2 unlocks `C`):

```
✓ Figma URL captured. State canvas created at LWC_BUILD_STATE.md.

Step 2 of ~11 — Extracting your Brand Summary now.

? · C=state
```

Acknowledgement line rules:
- One `✓` prefix, one sentence, past tense.
- Names the concrete thing just decided or written. Not "great" or "got it."
- Blank line, then the progress label + question.
- Blank line, then the footer.

## Never

- Restate the plan the user just approved.
- Repeat the same summary twice.
- Say "Great!" / "Perfect!" / "Absolutely" / "I'd love to help."
- List everything you're about to do before doing it.
- Omit the `Step N of ~M` label.
- Print a standing option in the footer before it's unlocked.
- Show `R` in the persistent footer. Inline only, when a Failure Mode was just cited.
- Change M silently by more than 2. Always announce ±3+ shifts.
