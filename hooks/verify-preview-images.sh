#!/usr/bin/env bash
# lwc-to-agentforce-chat plugin — PreToolUse hook (preview-time image guard).
#
# Fires when Claude writes or edits a `*.preview.html` file (the mandatory
# visual-review artifact). Blocks the write when any http(s) image URL embedded
# in the preview returns a 4xx/5xx status, so a broken or hotlink-blocked image
# is caught the moment the preview is generated — before the user reviews it and
# long before any Salesforce metadata is wired. This is the preview-time
# complement to verify-image-urls.sh, which guards the later deploy.
#
# Only image-extension URLs (.jpg/.jpeg/.png/.gif/.webp/.svg) are checked. Local
# paths, inline data URIs, and non-image links are ignored — a first-pass preview
# with placeholder art has no http image URLs and passes untouched. The gate only
# bites once the user has supplied real product image URLs.
#
# Behavior:
#   - Non-Write/Edit tools: exit 0 (no-op)
#   - Writes/edits to files other than *.preview.html: exit 0 (no-op)
#   - Preview with all image URLs 2xx (or none): exit 0 (allow)
#   - Preview with any image URL 4xx/5xx: exit 2 (block, with fix path on stderr)
#   - Network errors (curl fails, host unreachable): exit 0 (do not block on
#     offline runs; the skill still enforces verification in-chat)

set -uo pipefail

INPUT=$(cat)

# Extract tool name and target file path (grep/sed only — no jq dependency).
TOOL=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
FILE=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

# Bail unless this is a Write/Edit targeting a *.preview.html file.
case "$TOOL" in
  Write|Edit|MultiEdit) ;;
  *) exit 0 ;;
esac
echo "$FILE" | grep -qE '\.preview\.html$' || exit 0

# Extract image URLs from the tool input JSON (the preview markup lives in the
# `content` / `new_string` fields of the same payload). Case-insensitive
# extension match; excludes quotes, whitespace, and angle brackets.
IMAGE_URLS=$(echo "$INPUT" | grep -oiE 'https?://[^"'"'"' <>\\]+\.(jpg|jpeg|png|gif|webp|svg)([?][^"'"'"' <>\\]*)?' | sort -u)

# No http image URLs → allow. Normal for a placeholder-art first preview.
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
  echo "Preview image URL verification failed — do NOT write this preview yet."
  echo ""
  echo "These image URLs in ${FILE} returned a 4xx/5xx status:"
  echo ""
  printf "%s" "$FAILED" | sed 's/^/  /'
  echo ""
  echo "Fix path (catch broken images at preview time, not after the metadata is wired):"
  echo "  1. Re-copy the image address from the product page (right-click the main image -> Copy Image Address)."
  echo "  2. If a host hotlink-blocks (e.g. returns 403), ask the user for a URL that loads, or fall back to a stable placeholder for that slot."
  echo "  3. Curl each replacement to confirm 200, then re-write the preview so the user only ever reviews images that actually load."
  echo ""
  echo "This check runs before every *.preview.html write via the lwc-to-agentforce-chat plugin hook."
} >&2
exit 2
