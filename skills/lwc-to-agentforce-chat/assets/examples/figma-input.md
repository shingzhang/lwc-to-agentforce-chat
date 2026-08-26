# Example — Entry 1 (Figma) walked through

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

```
Step 1 of ~12 — Path picked: Entry 1 (Figma → LWC → chat).

Step 2 of ~12 — Fetching the Figma frame. Preview URL:
  <the-URL-you-pasted>
  Reply YES to proceed.

[user: YES]

✓ Step 3 of ~12 — Extracted brand tokens from Figma.

  What: Pulled primary <#RRGGBB>, secondary <#RRGGBB>, accent <#RRGGBB>,
        font <family>, radius <N>px, shadow <css-shadow>
        from frame <node-id>.
  Why:  These become the LWC's CSS variables so the card matches
        the customer's brand instead of rendering generic gray/white.
  Next: Step 4 — I'll infer which of the 4 preset patterns this
        Figma matches.

? · C=state · S=switch path
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
| Invocable service | `<Prefix>ShoppingCarouselController` |
| Agent Script action | `show_carousel` |

From here the skill walks Steps 4–12 (pattern confirm → naming → preview
Piece 1 → preview Piece 2 → ... → deploy checkpoint) with a What/Why/Next
block after each write.
