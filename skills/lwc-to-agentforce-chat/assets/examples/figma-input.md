# Example — Entry 1 (Figma) walked through

> Fully fictional. "Willa's Corner Grocery" is a made-up retail brand used
> throughout this skill's examples. No real customer data.

## Scenario

Willa's Corner Grocery is a fictional neighborhood specialty grocery. The
design team has mocked up a **shopping carousel** that should render inside
an Agentforce chat bubble whenever a shopper asks the agent "what should
I make for dinner tonight?"

The designer hands the developer a Figma URL and says "here's the design,
please wire it up."

## Input

```
User: I have a Figma design I want to render in my Agentforce chat.
      https://www.figma.com/design/EXAMPLE/willa-shopping-carousel?node-id=1-42
```

## What the skill emits

```
Step 1 of ~12 — Path picked: Entry 1 (Figma → LWC → chat).

Step 2 of ~12 — Fetching the Figma frame. Preview URL:
  https://www.figma.com/design/EXAMPLE/willa-shopping-carousel?node-id=1-42
  Reply YES to proceed.

[user: YES]

✓ Step 3 of ~12 — Extracted brand tokens from Figma.

  What: Pulled primary #2E5D3B, secondary #F4EBDA, accent #E4A853,
        font Sora, radius 12px, shadow 0 2px 12px rgba(0,0,0,0.06)
        from frame node-1-42.
  Why:  These become the LWC's CSS variables so the card matches
        Willa's brand instead of rendering generic gray/white.
  Next: Step 4 — I'll infer which of the 4 preset patterns this
        Figma matches.

? · C=state · S=switch path
```

## Brand Summary produced

```
Brand Summary
─────────────────────────────
Primary:    #2E5D3B (Willa Sage)
Secondary:  #F4EBDA (Cream)
Accent:     #E4A853 (Honey)
Text:       #1F2A24
Background: #FFFFFF
Font:       Sora
Border R:   12px
Shadow:     0 2px 12px rgba(0,0,0,0.06)
─────────────────────────────
```

## Pattern inference

> **Detected: shopping carousel.**
> Reason: 4 identical horizontal siblings with image + text + price nodes.

## Naming derived from prefix `wsi` (fictional)

| Piece | Identifier |
|---|---|
| LWC bundle | `wsiShoppingCarousel` |
| LightningType folder | `Wsi_ShoppingCarousel` |
| Apex DTO class | `WsiShoppingCarouselData` |
| Invocable service | `WsiShoppingCarouselController` |
| Agent Script action | `show_carousel` |

From here the skill walks Steps 4–12 (pattern confirm → naming → preview
Piece 1 → preview Piece 2 → ... → deploy checkpoint) with a What/Why/Next
block after each write.
