# Figma Extraction — reference

## When this reference applies

Consulted from Entry point 1 of `lwc-to-agentforce-chat` — when the user has a Figma design (URL, share link, exported PNG, or JPG) and wants to turn it into an LWC that renders inside an Agentforce chat bubble. The parent skill routes here at Step 3 of Entry 1 (the "extract design tokens" step) and again at Step 4 (the "infer pattern from visual structure" step).

Not consulted from Entries 2, 3, or 4 unless the user pivots mid-flow. If Entry 4 (folder scan) detects Figma-shaped assets and the user picks Entry 1, we land here. If the user provided a public URL at Step 1 as source material, we run this reference before the surface picker even shows.

## Path A — Figma MCP (if available in the session)

**How to detect.** Availability is decided by tools in the current session, not by config files. A server can be registered in config and still be unavailable (unauthenticated, disconnected, or crashed). Check in this order:

1. Look for `mcp__figma__*` tool names in the current session's available tools. This is the authoritative check.
2. If no such tools exist, inspect `<plugin-root>/.mcp.json`, `<project-root>/.mcp.json`, or `~/.claude/settings.json` for an `mcpServers` entry whose name or URL contains `figma`. If one is found but no tools exist, the MCP is registered but not authenticated or not connected — surface that state to the user (see the fallback message below).

If step 1 hits, Path A is available. Otherwise fall through to Path B or C, and tell the user why (registered-but-unauthenticated vs. not-registered-at-all is a meaningful difference for troubleshooting).

**What to fetch.** Given the user's Figma URL (or a specific `node-id` query param), request:
- **Frame by ID** — if the URL includes `?node-id=X-Y`, fetch just that frame's subtree.
- **Top-level page** — otherwise fetch the page and pick the largest visible frame.

Extract from the returned node tree:
- **Node tree** — hierarchy of frames, groups, components, text nodes.
- **Styles** — fill colors (as hex), stroke, effects (drop shadow).
- **Component names** — anything published as a component (they usually match brand-system names).
- **Exact tokens** — every fill color, font-family, font-weight, font-size, letter-spacing, corner radius, spacing (padding/margin), shadow (blur/spread/color).

**Structured output shape.** Emit the Brand Summary format (mirrors `experience-cloud-site-builder` Phase 1.2, line 566):

```
Brand Summary
─────────────────────────────
Primary:    #C41E3A (Retail Red)
Secondary:  #1A1A1A
Accent:     #FFB81C
Text:       #333333
Background: #FFFFFF
Font:       Inter
Border R:   8px
Shadow:     0 2px 8px rgba(0,0,0,0.08)
Spacing:    4, 8, 12, 16, 24, 32 (px scale)
─────────────────────────────
```

The `Spacing:` row is new vs v1 — Figma MCP gives us the design's spacing scale for free, which v1's URL-scraping path can't.

**Pattern inference.** From the frame structure, guess which of the four preset patterns applies:

| If the frame contains… | Recommend pattern |
|---|---|
| ≥3 identical horizontal siblings with image + text + price nodes | **shopping carousel** |
| A date grid (7-column layout) + a time-slot pill group | **appointment scheduler** |
| A status timeline (dot-line-dot-line-dot horizontal or vertical) | **order status card** |
| A vertical 3-card stack with a reasoning-line text node above | **product picks** |
| Anything else | Ask user; fall back to `experience-cloud-site-builder` full wizard |

Print the recommendation with the reasoning (a one-sentence explanation of which visual cue you keyed on).

## Path B — WebFetch (public Figma URL)

**When to use.** Figma MCP is unavailable in this session (no `mcp__figma__*` tools), and the URL is a public/shared Figma link that returns rendered HTML. Note: `figma.com/design/…?m=dev` editor URLs are a canvas SPA and typically return only the login shell to WebFetch — for those, Path A (MCP) or Path C (screenshot) is the working route. When falling back to Path B, say why explicitly, e.g. "Figma MCP is registered but not authenticated — run `/mcp` to authenticate. Falling back to WebFetch."

**Command shape.**
```
WebFetch(
  url=<figma-share-url>,
  prompt="Extract primary/secondary/accent colors from CSS vars, inline styles; font-family; border-radius; shadow; logo URL. Return as a structured list."
)
```

**What we lose vs MCP.**
- No structured node access — we're reading rendered CSS from the shared-view page, not the source-of-truth design.
- No spacing scale — must eyeball from screenshots or infer defaults.
- No component names — we don't know if a card is "Product Card" or just an anonymous group.

**Limitations.**
- Only works on public Figma URLs (or shared links with view access).
- Private files require MCP or a manual export.
- Figma's shared-view HTML has changed before; if extraction returns nothing, fall through to Path C.

## Path C — Screenshot (PNG/JPG)

**When to use.** User has an exported image and no public URL. Or Path B extraction returned insufficient tokens.

Use the Read tool to load the image visually:
- Colors — sample from the rendered pixels (primary is usually the most-saturated large area; accent is the CTA button).
- Typography — read visible text; if font family isn't obvious, ask user or default to Inter.
- Spacing — measure gaps between siblings visually; convert to px scale.

Less precise but always available. Best when the user's design isn't in Figma anyway (Sketch, Illustrator, Photoshop exports work fine).

## Load-bearing checkpoint: URL preview before WebFetch

Before Path B fires, print the URL and require YES:

```
About to fetch this Figma URL:

  https://www.figma.com/design/EXAMPLE/example-shopping-carousel?node-id=1-42

Some Figma URLs carry tokens or session IDs in the path. Confirm this
URL is safe to fetch — it will pass through WebFetch and may hit logs.

Reply YES to proceed, or paste a different URL / an exported PNG path.
```

Do not fetch until YES. If the user pastes a screenshot path instead, switch to Path C without asking again.

## Brand Summary output shape

Print this exact shape after extraction completes (regardless of which path ran). The parent skill uses this as input to Step 5's Brand Summary confirmation:

```
Brand Summary
─────────────────────────────
Primary:    #C41E3A (Retail Red)
Secondary:  #1A1A1A
Accent:     #FFB81C
Text:       #333333
Background: #FFFFFF
Font:       Inter
Border R:   8px
Shadow:     0 2px 8px rgba(0,0,0,0.08)
Spacing:    4, 8, 12, 16, 24, 32
─────────────────────────────

Reply YES to proceed, or describe corrections
(e.g., "primary should be #D01E3A", "font should be Poppins").
```

If Path B ran, omit `Spacing:` (we don't have it). If Path C ran, add `(inferred)` next to any token that wasn't clearly visible.

## Cross-references

**REQUIRED:** Use `experience-cloud-site-builder` Phase 1.2 for the underlying Brand Summary shape, the "URL / screenshot / manual" three-option pattern, and the Manual fallback (colors + font + logo as literal user input).

**RECOMMENDED:** Use `applying-slds` for translating extracted tokens into SLDS styling hooks if the LWC should map to SLDS design tokens rather than raw hex — e.g., `--slds-c-button-brand-color-background` instead of `#C41E3A`. This matters when the customer wants their card to inherit theme updates without re-deploying the LWC.
