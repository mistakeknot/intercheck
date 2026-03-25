#!/usr/bin/env bash
# Auto-format — runs language-specific formatters after Edit/Write.
# Silent on success and failure. Best-effort — missing formatters are skipped.
#
# Runs AFTER syntax-check. If syntax is broken, the formatter may still run
# (most formatters handle syntax errors gracefully).
#
# Supported: ruff (Python), shfmt (Shell), gofmt (Go), jq (JSON), prettier (TS/JS)
set -uo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/intercheck-lib.sh"

INPUT=$(cat)
SID=$(_ic_session_id "$INPUT")
FP=$(_ic_file_path "$INPUT")
[[ -z "$FP" || ! -f "$FP" ]] && exit 0

LANG=$(_ic_detect_lang "$FP")
FORMATTED=false

case "$LANG" in
  python)
    if command -v ruff &>/dev/null; then
      ruff format --quiet "$FP" 2>/dev/null && FORMATTED=true
    fi
    ;;
  shell)
    if command -v shfmt &>/dev/null; then
      shfmt -w "$FP" 2>/dev/null && FORMATTED=true
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FP" 2>/dev/null && FORMATTED=true
    fi
    ;;
  json)
    if command -v jq &>/dev/null; then
      if jq . "$FP" > "${FP}.ic-tmp" 2>/dev/null; then
        mv "${FP}.ic-tmp" "$FP" && FORMATTED=true
      else
        rm -f "${FP}.ic-tmp"
      fi
    fi
    ;;
  typescript|javascript)
    # Only run prettier if node_modules exists nearby (avoid npx cold start)
    if command -v npx &>/dev/null; then
      local_nm="$(dirname "$FP")/node_modules"
      root_nm="./node_modules"
      if [[ -d "$local_nm" || -d "$root_nm" ]]; then
        npx prettier --write "$FP" 2>/dev/null && FORMATTED=true
      fi
    fi
    ;;
esac

# Track format count in state (no output — formatting is silent)
if [[ "$FORMATTED" == "true" && -n "$SID" ]]; then
  SF=$(_ic_state_file "$SID")
  STATE=$(_ic_read_state "$SF")
  NEW_STATE=$(echo "$STATE" | jq '.format_runs = (.format_runs + 1)')
  _ic_write_state "$SF" "$NEW_STATE"
fi
