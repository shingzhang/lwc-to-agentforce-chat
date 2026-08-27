# Example — Figma walkthrough

> Generic walkthrough. Bring your own public Figma URL. Placeholder brand
> tokens below are illustrative only.

## Scenario

The design team has mocked up a **shopping carousel** that should render
inside an Agentforce chat bubble whenever a shopper asks the agent
"what should I make for dinner tonight?"

The designer hands the developer a Figma URL and says "here's the design,
please wire it up."

## Input

```
User: I have a Figma design I want to render in my Agentforce chat.
      <paste-your-public-figma-share-url>
```

## What the skill emits

Since a Figma URL arrived with the first message, the skill skips the
opening prompt and goes straight to Step 2 (extraction):

```
✓ Figma URL captured. State canvas created at LWC_BUILD_STATE.md.

Step 2 of ~11 — Fetching the Figma frame. Preview URL:
  <the-URL-you-pasted>
  Reply YES to proceed.

[user: YES]

✓ Step 2 of ~11 — Extracted brand tokens from Figma.

  What: Pulled primary <#RRGGBB>, secondary <#RRGGBB>, accent <#RRGGBB>,
        font <family>, radius <N>px, shadow <css-shadow>
        from frame <node-id>. Pattern inferred: shopping_carousel.
  Why:  These become the LWC's CSS variables so the card matches
        the customer's brand instead of rendering generic gray/white.
        Extracting the pattern now means the HTML preview at Step 3
        matches your design instead of a generic template.
  Next: Step 3 — I'll generate a full HTML preview of the card so you
        can review it in a browser before we transform to LWC.

? · C=state
```

## Brand Summary produced

```
Brand Summary
─────────────────────────────
Primary:    #<hex> (<label>)
Secondary:  #<hex>
Accent:     #<hex>
Text:       #<hex>
Background: #<hex>
Font:       <family>
Border R:   <N>px
Shadow:     <css-shadow>
Pattern:    shopping_carousel (high confidence)
─────────────────────────────
```

## Pattern inference

> **Detected: shopping carousel.**
> Reason: 4 identical horizontal siblings with image + text + price nodes.

## Naming derived from prefix `<prefix>` (choose your own)

| Piece | Identifier |
|---|---|
| LWC bundle | `<prefix>ShoppingCarousel` |
| LightningType folder | `<Prefix>_ShoppingCarousel` |
| Apex DTO class | `<Prefix>ShoppingCarouselData` |
| Invocable service | `<Prefix>ShoppingCarouselService` |
| Agent Script action | `show_carousel` |

From here the skill walks Steps 3–11 (HTML preview + review → LWC transform
→ naming → preview Piece 1 → preview Piece 2 → ... → deploy checkpoint)
with a What/Why/Next block after each write. The HTML preview at Step 3 is
mandatory and non-skippable; the skill does not generate the LWC bundle
until the user replies YES to the preview.
