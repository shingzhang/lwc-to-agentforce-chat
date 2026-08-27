# Fixture: Meadowbrook Market product cards

Fully fictional. No real customer, URL, or brand token.

## What's in here

- `product-card.png` — a 3-card retail product row, sized 1200×620. Mirrors what a Figma frame export would look like once you drop it into `figma-extractor` as a Path C (image) input.
- `expected-brand-summary.json` — the Brand Summary the extractor should return for this image, plus the pattern inference (`shopping_carousel`, high confidence).

## How to use it as the plugin's 30-second demo

From the plugin repo root, in a Claude Code session with the plugin installed:

```
> I have a Figma export I want in an Agentforce chat card. Use fixtures/example-figma/product-card.png
```

The skill triggers on the natural-language intent, picks up the PNG path from the first message, and runs Step 2 (extraction via `figma-extractor` Path C). Compare what the agent returns to `expected-brand-summary.json`. Small differences are expected — the extractor infers `font_family` visually and there is no embedded webfont in the PNG.

After Step 2, the skill generates the intermediary HTML preview at Step 3. That is where the design-review moment lives. Approve it, and the skill proceeds through Step 4 (LWC transform) and the 5-piece contract.

No Salesforce org is required for Steps 1–4. The deploy checkpoint at Step 11 is where org auth becomes necessary, and the skill previews the deploy commands rather than running them.

## Why this fixture, not a Figma URL

A Figma URL fixture would go stale the moment the file is edited, renamed, or made private. A PNG fixture is stable, small, and exercises the same code path as a real Figma → PNG export.
