#!/usr/bin/env bash
# lwc-to-agentforce-chat plugin — PreToolUse hook.
#
# Blocks `sf project deploy` when any image URL in the Apex classes about to
# be deployed returns a 4xx/5xx status. Guards against Failure Mode #8, where
# the LWC's image error handler silently hides broken images and the chat
# card renders with blank product slots.
#
# Only image-extension URLs (.jpg/.jpeg/.png/.gif/.webp/.svg) are checked —
# other link values (product URLs, docs) are ignored to avoid false positives
# on redirects and dynamic pages.
#
# Behavior:
#   - Non-Bash tools: exit 0 (no-op)
#   - Bash commands that are not `sf project deploy`: exit 0 (no-op)
#   - Deploy with all image URLs 2xx: exit 0 (allow)
#   - Deploy with any image URL 4xx/5xx: exit 2 (block, with fix path on stderr)
#   - Network errors (curl fails, host unreachable): exit 0 (do not block on
#     offline runs; the skill still enforces verification in-chat)

set -uo pipefail

INPUT=$(cat)

# Extract tool name and command (grep/sed only — no jq dependency).
TOOL=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
CMD=$(echo "$INPUT"  | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"'   | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

# Bail unless this is a Bash `sf project deploy` invocation.
[ "$TOOL" = "Bash" ] || exit 0
echo "$CMD" | grep -qE 'sf +project +deploy' || exit 0

# Determine scan root: --source-dir / --sourcepath / -d if given, else default SFDX path.
SCAN_ROOT=""
if echo "$CMD" | grep -qE '(--source-dir|--sourcepath|-d)[[:space:]]'; then
  SCAN_ROOT=$(echo "$CMD" | grep -oE '(--source-dir|--sourcepath|-d)[[:space:]]+[^[:space:]]+' | head -1 | awk '{print $2}')
fi

if [ -z "$SCAN_ROOT" ] || [ ! -d "$SCAN_ROOT" ]; then
  SCAN_ROOT="force-app/main/default/classes"
fi

# Nothing to scan → allow. This is normal for LWC-only deploys.
[ -d "$SCAN_ROOT" ] || exit 0

# Extract image URLs from *.cls files. Case-insensitive extension match.
# Excludes quotes, whitespace, and angle brackets from URL body.
IMAGE_URLS=$(grep -rhoiE 'https?://[^"'"'"' <>]+\.(jpg|jpeg|png|gif|webp|svg)([?][^"'"'"' <>]*)?' "$SCAN_ROOT" 2>/dev/null | sort -u)

# No image URLs → allow. Most deploys won't have them.
[ -n "$IMAGE_URLS" ] || exit 0

# Verify each URL. Block on 4xx / 5xx. Skip 000 (network error) so offline
# work isn't blocked — the skill still tells the model to verify in-chat.
FAILED=""
while IFS= read -r url; do
  [ -z "$url" ] && continue
  status=$(curl -sL -o /dev/null -w "%{http_code}" -A "Mozilla/5.0" --max-time 10 "$url" 2>/dev/null || echo "000")
  case "$status" in
    2*) ;;
    4*|5*) FAILED="${FAILED}${status}  ${url}"$'\n' ;;
    *) ;;
  esac
done <<< "$IMAGE_URLS"

[ -n "$FAILED" ] || exit 0

# Block. Write the fix path to stderr so Claude reads it via the tool error.
{
  echo "Image URL verification failed — do NOT proceed with this deploy."
  echo ""
  echo "These image URLs in ${SCAN_ROOT} returned a 4xx/5xx status:"
  echo ""
  printf "%s" "$FAILED" | sed 's/^/  /'
  echo ""
  echo "Fix path (Failure Mode #8 — broken images render as blank slots in chat):"
  echo "  1. Try WebFetch on any brand or product URL the user has already mentioned to source real image URLs."
  echo "  2. If that fails, ask the user for verified image URLs (they can paste them directly)."
  echo "  3. Update the .cls file with the working URLs. Curl each one to confirm 200 before retrying the deploy."
  echo ""
  echo "This check runs before every 'sf project deploy' via the lwc-to-agentforce-chat plugin hook."
} >&2
exit 2
