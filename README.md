# lwc-to-agentforce-chat

Turn a Figma design into a Lightning Web Component that renders inside an Agentforce chat bubble. The mandatory HTML preview step in the middle lets you review the design in a browser before it becomes LWC.

`v0.4.3` · `experimental` · `Salesforce` · `Agentforce` · `LWC`

---

## Who this is for

- A Salesforce front-end developer at an enterprise customer who owns Agentforce in-chat experiences. Common in retail (product carousels), financial services (account cards), and service industries (appointment booking, order status).
- They already have a Figma design. The expensive part is wiring it into the five metadata pieces the chat renderer expects.

## What it does

- **One linear flow with a design-review moment.** Figma → HTML preview (open in your browser and eyeball it) → LWC bundle → 5-piece contract (Apex DTO + LightningType bundle + LWC bundle + Invocable Apex + Agent Script).
- **The HTML preview step is non-skippable.** LWC has no mid-build browser preview. The intermediary HTML catches misread Figma tokens *before* the transform + write cycle burns time on LWC files you'll have to redo.
- **Reads Figma through the official MCP.** The plugin registers the link-based remote server at `mcp.figma.com`. Once you authenticate through `/mcp`, the `figma-extractor` agent pulls structured design tokens (colors, typography, spacing, node structure) from a Figma share link. PNG export is the offline fallback; the Figma desktop app is optional.
- **Teaches at every step.** Every question is labeled `Step N of ~M — <topic>`. Every substantive action prints a `What / Why / Next` micro-block grounded in a specific LWC constraint or known failure mode.
- **Never writes to `force-app/` or runs `sf project deploy` without explicit YES.** Load-bearing checkpoints are non-negotiable — planning, implementation, and demo are 100% local until you type YES.
- **Blocks `sf project deploy` when image URLs in Apex classes 404.** A PreToolUse hook (`hooks/verify-image-urls.sh`) scans `*.cls` files in the selected source directory for `.jpg` / `.png` / `.gif` / `.webp` / `.svg` URLs before every deploy and fails the command with a fix path if any return 4xx/5xx. Prevents Failure Mode #8 (broken images render as blank slots in the chat card) from reaching a running org.

## Install (fresh clone, <5 min)

From a fresh clone, add the repo as a local marketplace and install the plugin:

```bash
git clone https://github.com/shingzhang/lwc-to-agentforce-chat.git
cd lwc-to-agentforce-chat
claude plugin marketplace add ./
claude plugin install lwc-to-agentforce-chat@shing-plugins
```

The trailing `/` on `./` matters. `claude plugin marketplace add .` returns `Invalid marketplace source format` on Claude Code 2.1.152+.

For a one-session smoke test without installing, run:

```bash
claude --plugin-dir .
```

No Salesforce auth is required to install or run the local HTML demo.

## Try it in 30 seconds

The bundled fixture at `fixtures/example-figma/` is the fastest way to see the full flow. It ships a 1200×620 PNG of a fictional 3-card retail product row plus the Brand Summary the extractor should return. From the plugin repo root, in a Claude Code session with the plugin installed:

```
claude
> I have a Figma export I want in an Agentforce chat card. Use fixtures/example-figma/product-card.png
```

The skill triggers, picks up the PNG path from your message, and runs the `figma-extractor` agent via Path C (image). Compare its output against `fixtures/example-figma/expected-brand-summary.json`. Then the skill writes `<component>.preview.html` at Step 3 for you to open in a browser and approve. YES advances to Step 4 (LWC transform) and the 5-piece contract.

Steps 1–4 need no Salesforce org. Step 11 (deploy) is where org auth kicks in, and the skill only previews the deploy commands. You run them.

**Bringing your own Figma?** Same entry point, paste a Figma URL or a local PNG path instead of the fixture path.

**Namespaced slash command** (also works):

```
/lwc-to-agentforce-chat:lwc-in-chat
```

Drops you straight into the Step 1 prompt for a Figma source.

## What's inside

```
lwc-to-agentforce-chat/
├── .claude-plugin/plugin.json      ← plugin manifest
├── .claude-plugin/marketplace.json ← local fresh-clone install catalog
├── .mcp.json                       ← official remote Figma MCP server
├── README.md                       ← this file
├── GUIDE.md                        ← "build your own plugin" one-pager
├── CONTRIBUTING.md                 ← contributor principles
├── CHANGELOG.md
├── commands/
│   └── lwc-in-chat.md              ← namespaced compatibility shortcut
├── skills/
│   └── lwc-to-agentforce-chat/     ← the skill (SKILL.md + references/ + assets/)
├── agents/
│   └── figma-extractor.md          ← subagent for heavy Figma processing
├── hooks/
│   ├── hooks.json                  ← PreToolUse hook registration
│   └── verify-image-urls.sh        ← blocks sf project deploy on 4xx/5xx image URLs
└── fixtures/
    └── example-figma/      ← 30-second demo fixture: fictional 3-card PNG + expected Brand Summary
```

## Guardrails

- **No writes to any Salesforce sandbox.** Planning, implementation, and demo are 100% local.
- **Every file write under `force-app/` requires explicit YES.** Load-bearing checkpoint — no exceptions.
- **Every `sf project deploy` command is your next step, not the skill's.** The skill previews commands and prints them; you run them.
- **Figma URL fetches preview the URL before hitting `WebFetch`.** Share URLs can contain tokens — you confirm before it enters WebFetch logs.
- **Fictional or user-supplied inputs only.** The bundled fixture uses invented names and generic HTML. No real customer names, URLs, or brand tokens ship in this repo. The skill runs against whatever Figma URL you paste in.

## Set up Figma MCP

The plugin ships with Figma's official remote MCP (`https://mcp.figma.com/mcp`) declared in `.mcp.json`. That server gives the `figma-extractor` agent structured access to Figma designs (colors, typography, spacing, node structure). Registration happens automatically when the plugin installs, but the MCP starts unauthenticated. You have to complete OAuth before its tools become available in the session.

**Prerequisites:**

- Figma account (any tier).
- The Figma file must be accessible by the account you authenticate with. Public share URLs work for anyone; private files require you to be a collaborator.

The remote MCP at `mcp.figma.com` is link-based. It does not require the Figma desktop app. The desktop-app requirement applies to Figma's separate *local* MCP server, which this plugin does not ship. Some newer Figma features (Dev Mode selections, "Copy link to selection") are more convenient from the desktop app, but they are not prerequisites.

**Auth flow:**

1. In a Claude Code session, run `/mcp`.
2. Find `plugin:lwc-to-agentforce-chat:figma` in the list. It shows `! Needs authentication`.
3. Select it. A browser tab opens for Figma OAuth. Approve.
4. Quit Claude Code fully and relaunch (a soft reload isn't enough — MCP connections attach at session start).
5. Verify with `claude mcp list`. The figma entry should now show `✔ Connected`.

**Using it during the walkthrough:**

1. Grab a share link for the frame you want to convert. Easiest routes: right-click the frame in the desktop app and choose **Copy link to selection**, or use the Share button in the web app. Either yields a URL with a `?node-id=X-Y` fragment.
2. Paste that URL when the skill asks for a Figma source at Step 1.
3. The `figma-extractor` agent picks Path A (MCP) automatically and returns a Brand Summary plus pattern inference.

If the MCP is unavailable in the session (unauthenticated, disconnected, or removed), the skill falls back to Path B (WebFetch on a public share URL) or Path C (a PNG export you paste in). Path B does **not** work on `figma.com/design/…?m=dev` editor URLs — those are canvas SPAs. Use Path A (authenticated MCP) or Path C (screenshot) for editor URLs.

## Troubleshooting

**The skill said "No Figma MCP is configured" but I know it is.**

The check for Figma MCP availability looks at tools in the current session, not just config files. A `.mcp.json` entry means the MCP is *registered*, but the `mcp__figma__*` tools only appear once the MCP is authenticated and connected. Run `/mcp`, complete OAuth for `plugin:lwc-to-agentforce-chat:figma`, and fully relaunch Claude Code.

**WebFetch fell back but returned nothing useful.**

`figma.com/design/…?m=dev` and other Figma editor URLs are canvas SPAs. WebFetch only sees the login shell. Options:

- Authenticate the Figma MCP (above) and re-run.
- Export the frame as a PNG from Figma and point the skill at the local path. The extractor supports Path C (image-based extraction).
- If the design is public, use a share URL from Figma's "Share" button instead of the editor URL bar.

**`claude plugin install .` says "not found in any configured marketplace."**

`claude plugin install <path>` doesn't accept a path directly. Use the two-step flow: `claude plugin marketplace add ./` first, then `claude plugin install lwc-to-agentforce-chat@shing-plugins`.

**I moved the plugin folder and the install broke.**

The marketplace registration stores an absolute path. After moving, re-point it:

```
claude plugin uninstall lwc-to-agentforce-chat@shing-plugins
claude plugin marketplace remove shing-plugins
claude plugin marketplace add /new/absolute/path/to/lwc-to-agentforce-chat
claude plugin install lwc-to-agentforce-chat@shing-plugins
```

**MCP still shows "Needs authentication" after I clicked through OAuth.**

Quit Claude Code fully and relaunch — a Cmd-R reload isn't enough. MCP connections attach at session start. If it persists after a full relaunch, run `/mcp` and re-authenticate. If you're behind a corporate proxy that intercepts TLS, check that `NODE_EXTRA_CA_CERTS` is set in `~/.claude/settings.json` to your CA bundle path.

**The skill asks for `LWC_BUILD_STATE.md` before I have a project.**

Two valid answers:

- Reply with an absolute path to any writable directory. The skill writes a progress file there.
- Reply `not yet`. The skill holds state in-memory until you provide a path later.

**The skill previews a URL and asks for YES before every fetch.**

By design. This is one of the skill's load-bearing checkpoints. Some Figma URLs contain view tokens or session identifiers; the preview lets you confirm before the URL enters WebFetch logs. Reply `YES` to proceed, `N` to switch to a screenshot, or paste a different URL.

**The skill doesn't trigger when I paste a Figma URL.**

The skill triggers on natural-language intent (e.g., "I have a Figma design I want to render in my Agentforce chat"). A bare URL isn't enough context. Force the entry with `/lwc-to-agentforce-chat:lwc-in-chat`, or start with a sentence that names the intent.

**`claude plugin list` doesn't show the plugin.**

Two common causes:

- The marketplace was added but the plugin wasn't installed. Run `claude plugin install lwc-to-agentforce-chat@shing-plugins`.
- The plugin installed but was disabled. Run `claude plugin enable lwc-to-agentforce-chat@shing-plugins`.

**Deploy step says the Salesforce CLI isn't available.**

The plugin never runs `sf` commands autonomously. It previews the deploy command and asks you to run it yourself. If you don't have `sf` installed, follow the [Salesforce CLI install guide](https://developer.salesforce.com/tools/salesforcecli). The plugin's 30-second demo path (`fixtures/example-figma/`) works entirely offline, without `sf`.

**`sf project deploy` is being blocked with an "Image URL verification failed" message.**

The PreToolUse hook at `hooks/verify-image-urls.sh` scanned `*.cls` files in the selected source directory, found a `.jpg` / `.png` / `.gif` / `.webp` / `.svg` URL, and curl returned a 4xx or 5xx status on it. This is intentional — Failure Mode #8 (broken images render as blank slots in the chat card) is one of the most common ways an in-chat LWC ships silently broken. Follow the three-step fix path printed on stderr: attempt WebFetch on any brand URL the user has already mentioned, ask the user for verified URLs if that fails, then curl each new URL to 200 before retrying the deploy. Non-image URLs (product page links, docs) are not checked. In an offline run, the hook exits 0 on curl network errors (status `000`) so a network outage does not block a deploy.

## With more time

I would add fixture-driven checks for the generated metadata contract and run the complete workflow against a second enterprise design system to expose assumptions hidden by the retail example. I would also restore HTML and existing-LWC entry paths only after user testing shows that the additional flexibility is worth the larger decision surface. Those extensions would improve confidence and reach without weakening the plugin's intentionally narrow first-run experience.

## Uninstall

```
/plugin uninstall lwc-to-agentforce-chat
```

Or delete the plugin directory. Nothing was written to any Salesforce sandbox, so there's no cleanup on the org side.

MIT-licensed. See `LICENSE`.
