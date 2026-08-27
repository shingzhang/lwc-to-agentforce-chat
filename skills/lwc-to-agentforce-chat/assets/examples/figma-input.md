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

Step 2 of ~13 — May I send this exact Figma URL to WebFetch?
  <the-URL-you-pasted>
  Reply YES to proceed.

[user: YES]

✓ Step 2 of ~13 — Extracted brand tokens from Figma.

  What: Pulled primary <#RRGGBB>, secondary <#RRGGBB>, accent <#RRGGBB>,
        font <family>, radius <N>px, shadow <css-shadow>
        from frame <node-id>. Pattern inferred: shopping_carousel.
  Why:  These become the LWC's CSS variables so the card matches
        the customer's brand instead of rendering generic gray/white.
        Extracting the pattern now means the HTML preview at Step 3
        matches your design instead of a generic template.
  Next: Step 3 — I'll generate a full HTML preview of the card so you
        can review it in a browser before we transform to LWC.

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
| GenAI Function | `<Prefix>_Shopping_Carousel` |
| Agent bundle | `<Prefix>ShoppingAgent` |
| Permission set | `<Prefix>_Shopping_Carousel_Access` |

From here the skill walks Steps 3–13 (HTML preview + review → LWC transform
→ naming → complete metadata generation → validate/dry-run/deploy)
with a What/Why/Next block after each write. The HTML preview at Step 3 is
mandatory and non-skippable; the skill does not generate the LWC bundle
until the user replies YES to the preview.
