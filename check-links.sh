#!/usr/bin/env bash
# check-links.sh — verify every image/link URL in README.md actually resolves.
#
# I could not run this for you: the sandbox I work in has no outbound network
# (every host blocked except one internal domain), so any result I reported
# would have been a guess. Run it on your own machine, where it's real.
#
#   chmod +x check-links.sh
#   ./check-links.sh README.md
#
# Exit code is the number of failing URLs, so it drops into CI cleanly.

set -uo pipefail

FILE="${1:-README.md}"

if [[ ! -f "$FILE" ]]; then
  echo "error: no such file: $FILE" >&2
  exit 2
fi

# Pull every http(s) URL out of src="...", href="...", srcset="..." and
# markdown (...) targets. Strip trailing quotes/parens/commas.
mapfile -t URLS < <(
  grep -oE 'https?://[^"'"'"' )>]+' "$FILE" \
    | sed -e 's/[),.]*$//' \
    | sort -u
)

echo "Checking ${#URLS[@]} unique URLs in $FILE"
echo

fail=0
declare -a FAILED=()

for u in "${URLS[@]}"; do
  # -L follow redirects, -A a real UA (some CDNs 403 curl's default)
  read -r code ctype < <(
    curl -s -o /dev/null -L --max-time 25 \
      -A 'Mozilla/5.0 (README link check)' \
      -w '%{http_code} %{content_type}\n' \
      "$u" 2>/dev/null
  ) || true

  code="${code:-000}"
  ctype="${ctype:-none}"

  case "$code" in
    2*)
      printf '  \033[0;32mOK  %s\033[0m  %-28s %s\n' "$code" "${ctype%%;*}" "$u"
      ;;
    3*)
      printf '  \033[0;33mRDR %s\033[0m  %-28s %s\n' "$code" "${ctype%%;*}" "$u"
      ;;
    000)
      printf '  \033[0;31mDEAD ---\033[0m %-28s %s\n' "no response" "$u"
      FAILED+=("$u  (no response — DNS failure or host gone)")
      ((fail++))
      ;;
    *)
      printf '  \033[0;31mFAIL %s\033[0m %-28s %s\n' "$code" "${ctype%%;*}" "$u"
      FAILED+=("$u  (HTTP $code)")
      ((fail++))
      ;;
  esac
done

echo
if (( fail == 0 )); then
  echo "All ${#URLS[@]} URLs responded successfully."
else
  echo "$fail of ${#URLS[@]} URLs need attention:"
  printf '  - %s\n' "${FAILED[@]}"
  echo
  echo "Notes on likely causes:"
  echo "  * raw.githubusercontent.com/.../output/*.svg  -> expected to 404 until"
  echo "    the snake workflow has run once. Not a real failure."
  echo "  * ./profile-3d-contrib/*.svg is a relative path and is not checked here."
  echo "  * github-readme-stats.vercel.app is rate-limited on the shared instance;"
  echo "    a 429 means try again later, not that the URL is wrong."
fi

exit "$fail"
