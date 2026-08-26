# Progress Labels — reference

Every question the skill asks carries a `Step N of ~M — <topic>` label. The `~` (tilde) is deliberate — the count can shift ±2 based on answers without breaking the promise. This gives the user a clear sense of "how much longer" without lying about the exact endpoint.

The label appears above the question. The compact-update line and footer sit below it. See `teaching-blocks.md` for the What/Why/Next micro-block that runs after each substantive action.

## Per-entry-point step budgets

| Entry point | Approx steps | Range (min–max) | Notes |
|---|---|---|---|
| Entry 1 (Figma) | ~12 | 10–14 | Step 3 (extract) can loop if extraction is thin |
| Entry 2 (HTML) | ~11 | 9–13 | Transform depth varies by HTML complexity |
| Entry 3 (Existing LWC) | ~9 | 6–12 | Depends on how many pieces already exist (Branch A/B/C) |
| Entry 4 (Folder scan) | ~7 + funnel | 4–9 + entry-point-N steps | Scan itself is fast; funnel adds the picked entry's steps |

## Step 1 is always the surface picker

Across all four entries, Step 1 is the same 4-option chooser from §A. This means:

- Entry 1: Step 1 = picker, Steps 2–12 = Figma path
- Entry 2: Step 1 = picker, Steps 2–11 = HTML path
- Entry 3: Step 1 = picker, Steps 2–9 = LWC retrofit path
- Entry 4: Step 1 = picker, Steps 2–7 = scan + recommendation, then funnel resets N for the picked path

## When to update M mid-flow

The tilde is a promise, not a lie. Reasons M can shift:

- **Entry 3 Branch A** (nothing exists) → M drops from 9 to ~11 because we're really running Entry 1 or 2 workflows under the hood.
- **Entry 3 Branch B** (LWC exists) → M is exactly 9. Tightest path.
- **Entry 3 Branch C** (partial pieces) → M is 6–8 depending on how many pieces already exist.
- **Entry 4** → after the funnel, M resets to the picked entry's M. Say so verbatim: `Step count reset — you're now in Entry 1, Step 3 of ~12.`
- **Any entry**: if user provides source material at Step 1 that pre-fills state (a URL, a file path, a project path), M shrinks by 2.

Rule: if the change is **±2**, keep the tilde and stay silent. If it's **±3 or more**, print an explicit `Step count updated: now ~N total` line before the next label.

## Footer format — progressive unlock

At Step 2 onward, print a footer showing currently-unlocked standing options. Short form only. Prefix with `?` so the user knows help is one keystroke away.

| Option | Unlocks when | Short-form footer |
|---|---|---|
| `C` — Show me what's been decided | After Step 2, once `LWC_BUILD_STATE.md` has been created | `C=state` |
| `S` — Switch between entry points | After Step 2, once a path is picked | `S=switch path` |
| `V` — Verify what's in the org vs. what's local | After the first successful deploy | `V=verify org` |
| `E` — Export handoff documentation | Entry 1/2 after Step 8, Entry 3 after Step 6, Entry 4 after funnel completes 3+ steps | `E=export docs` |
| `R` — Details on a cited rule / failure mode | Contextual only — surfaced inline when the skill just cited `Failure Mode #N` | inline: `Type R for details on Failure Mode #N` |

`R` never appears in the persistent footer — only inline, and only when a Failure Mode number was cited in the previous turn.

## Example footer progression

- **Step 1**: no footer (nothing actionable yet)
- **Step 2 onward**: `? · C=state · S=switch path`
- **After first deploy**: `? · C=state · S=switch path · V=verify org`
- **Entering test phase**: `? · C=state · S=switch path · V=verify org · E=export docs`

## Compact update lines

After every user answer, print one acknowledgement line + the next question, labeled with progress, followed by the currently-unlocked footer. Example (right after Step 2 unlocks `C` and `S`):

```
✓ Surface: Figma. State canvas created at LWC_BUILD_STATE.md.

Step 2 of ~12 — Paste your Figma URL, or point at an exported PNG/JPG file.

? · C=state · S=switch path
```

Acknowledgement line rules:
- One `✓` prefix, one sentence, past tense.
- Names the concrete thing just decided or written (not "great" or "got it").
- Blank line, then the progress label + question.
- Blank line, then the footer.

## Never

- Restate the plan the user just approved
- Repeat the same summary twice
- Say "Great!" / "Perfect!" / "Absolutely" / "I'd love to help"
- List everything you're about to do before doing it
- Omit the `Step N of ~M` label
- Print a standing option in the footer before it's unlocked
- Show `R` in the persistent footer (inline only, when a FM was just cited)
- Change M silently by more than 2 — always announce ±3+ shifts
