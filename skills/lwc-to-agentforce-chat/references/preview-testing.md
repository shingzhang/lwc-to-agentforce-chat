# Preview Testing + Image Hosts

Reference for the `lwc-to-agentforce-chat` skill. Covers the Preview-first testing surface, Employee agent configuration, image URL verification, and Trusted URL setup.

---

## 1. Preview vs ECV2 — pick Preview by default

Agentforce has two testing surfaces:

1. **Agent Builder Preview** — inline test panel in Setup → Agents → Open in Builder → Preview tab
2. **Enhanced Web Chat V2 (ECV2)** — external chat surface, requires ESD + channel wiring

Preview is more reliable for iteration:

- No ESD / EWCV2 setup
- No channel routing
- No customer chat host to keep Trusted URLs in sync with
- Runs as the previewing user (you), not a service user
- Immediate feedback loop after every deploy

**Default to Preview.** ECV2 setup is out-of-scope unless the user asks for a customer-facing chat surface.

---

## 2. Employee agent type — required for Preview

Preview only works with `agent_type: "AgentforceEmployeeAgent"`. If you leave `agent_type` off, Salesforce defaults to `EinsteinServiceAgent` — a service agent that Preview refuses to run (it expects a live `MessagingSession` record).

### Employee agent config

In your `.agent` file's `config:` block:

```
config:
    developer_name: "<name>"
    agent_label: "<label>"
    description: "..."
    agent_type: "AgentforceEmployeeAgent"
```

**Do NOT include:**

- `variables:` block — Preview has no MessagingSession to source `@MessagingSession.*` variables from
- `default_agent_user:` — Employee agents run as the previewing user

### CRITICAL — `agent_type` is immutable after v1 publish

Once you publish v1 of an agent, you cannot change `agent_type`. Salesforce enforces this at publish time:

> You can't modify 'agent_type' after first version is published.

**Workaround.** If a service agent was published first, rename the bundle folder + `developer_name` + `agent_label` to a new API name and publish that as a fresh v1. The old bundle stays as an orphan.

---

## 3. Agent naming — ask, don't invent

Every build creates an agent. Before writing the `.agent` file, ask:

```
Agent identity — before I write the .agent file:

  1) Create a new agent. What should the API name be? (PascalCase, no spaces)
  2) Reuse an existing agent (paste the API name)
```

If they pick an existing agent, retrieve it first:

```bash
sf project retrieve start -m AiAuthoringBundle:<name> --target-org <alias>
```

Then edit the retrieved `.agent` to add your subagent + action, rather than writing from scratch.

Never invent an agent name based on the customer or the LWC. That leads to bundle-name collisions and confusing orphans in the org.

---

## 4. Permset assignment — admin user, not service user

Employee agents run as the previewing author. Assign the permset to the CLI's authenticated admin user, NOT the service agent user:

```bash
sf org assign permset -n <PermsetName> --target-org <alias>
```

Do NOT pass `--on-behalf-of <service-user>` for Preview flow. The service user does not run the agent in Preview — you do, as the previewing author.

---

## 5. Image URL verification — mandatory before deploy

Every image URL in mock Apex data must return HTTP 200 before deploy. If a URL 404s, the LWC's image error handler (Failure Mode #8) hides the img element and the card renders with blank slots.

### Verification loop

```bash
for u in \
  "<url1>" \
  "<url2>" \
  "<url3>" \
  "<url4>"; do
  code=$(curl -o /dev/null -s -w "%{http_code}" -A "Mozilla/5.0" "$u")
  echo "$code  $u"
done
```

If any URL is not 200, stop and ask the user for a working URL — do NOT deploy with broken mock data.

### View one sample before deploying

Download and Read a sample URL to confirm the photo matches the product slot before deploying:

```bash
curl -sL -A "Mozilla/5.0" "<url>" -o /tmp/sample.jpg
```

Then Read the file to view it. Text saying "cookware" plus a photo of skincare is a bad demo. If the image mismatches the slot, swap the URL before deploy.

---

## 6. Watch for redirect chains

CSP validates the FINAL URL after any HTTP 302 redirect, not just the origin URL you trust.

Known redirect gotchas:

- `picsum.photos` → redirects to `fastly.picsum.photos`. Trusting only `picsum.photos` is not enough.
- Old `assets.wsimgs.com` URLs (rotated paths) → some 404, others 200. Verify each one.

To check whether a host redirects:

```bash
curl -sL -o /dev/null -w "final URL: %{url_effective}\n" -A "Mozilla/5.0" "<url>"
```

If `final URL` differs from the origin host, you need to trust the redirect target too — or pick a host that doesn't redirect.

---

## 7. Hosts that work well without redirects

Verified for this pattern:

- `images.unsplash.com` — direct, stable photo IDs, no redirect. ASA Product Assistant uses this.
- `assets.wsimgs.com` — direct if the URL path is real. Verify each URL.

---

## 8. Trusted URL setup — exact fields, not prose

When the user needs to add a Trusted URL, provide these exact fields:

```
Setup → Trusted URLs → New Trusted URL

  API Name:       <hostname>_com  (or similar snake_case, hostname-derived)
  URL:            <hostname>        (bare hostname, no protocol, no path)
  Description:    (optional)
  Active:         checked
  CSP Context:    All
  CSP Directives: img-src (images) ONLY  (unless the host also serves scripts, fonts, etc.)
```

**Do not check `script-src`** for image-only hosts. It's not needed and expands the CSP surface.

Repeat for each image host. If picsum.photos → fastly.picsum.photos, add both entries — or better, switch to a non-redirecting host.

---

## 9. Test prompt — always give the user one to paste

At the end of every build, print the recorded test prompt verbatim so the user can copy-paste into Preview:

```
Verify in Preview:

1. Setup → search "Agents" → click [Agent Label]
2. Click "Open in Builder"
3. Click the "Preview" tab
4. Paste this test prompt:

     show me the best cookware under $100

Expected: card renders inline with product photos.
```

Recorded at Step 6 (naming) alongside the agent identity, so it's always known when the deploy-checkpoint prints.

---

## 10. Deploy sequence with image verification

1. Write Piece 4 Apex with mock URLs.
2. Verify each URL returns 200 (§5).
3. Download one sample and Read it to confirm image content (§5).
4. If any 404s or content mismatches: ask user for real URLs. Do not deploy with placeholders that 404 or that mislead the demo.
5. Deploy Apex.
6. Ask user to add Trusted URL(s) with the exact fields above (§8).
7. Print the test prompt verbatim (§9).
8. User reruns Preview test.

---

## 11. Failure mode #8 refresher

`event.target.style.display = 'none'` in the LWC's image handler hides broken images. This is the intended behavior (better than a broken-image icon), but it means blank image slots when URLs 404. Verification at deploy time prevents this from reaching the user.
