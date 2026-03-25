#!/usr/bin/env bash
# Syntax check — validates code after every Edit/Write/NotebookEdit.
# Returns additionalContext with error details on failure. Silent on success.
#
# Supported: Python, Shell, JSON, TOML, YAML, Go, TypeScript, JavaScript
set -uo pipefail
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/intercheck-lib.sh"

INPUT=$(cat)
SID=$(_ic_session_id "$INPUT")
FP=$(_ic_file_path "$INPUT")
[[ -z "$FP" || ! -f "$FP" ]] && exit 0

LANG=$(_ic_detect_lang "$FP")
ERR=""

case "$LANG" in
  python)
    ERR=$(python3 -m py_compile "$FP" 2>&1 || true)
    # py_compile outputs nothing on success
    ;;
  shell)
    ERR=$(bash -n "$FP" 2>&1 || true)
    ;;
  json)
    ERR=$(python3 -c "
import json, sys
try:
    json.load(open('$FP'))
except Exception as e:
    print(e)
" 2>&1 || true)
    ;;
  toml)
    ERR=$(python3 -c "
import tomllib, sys
try:
    tomllib.load(open('$FP','rb'))
except Exception as e:
    print(e)
" 2>&1 || true)
    ;;
  yaml)
    ERR=$(python3 -c "
import sys
try:
    import yaml
    yaml.safe_load(open('$FP'))
except ImportError:
    pass
except Exception as e:
    print(e)
" 2>&1 || true)
    ;;
  go)
    if command -v go &>/dev/null; then
      ERR=$(go vet "$FP" 2>&1 || true)
    fi
    ;;
  typescript|javascript)
    if command -v node &>/dev/null; then
      ERR=$(node --check "$FP" 2>&1 || true)
    fi
    ;;
  *)
    exit 0
    ;;
esac

# Only output on error
if [[ -n "$ERR" ]]; then
  # Track error count in state
  if [[ -n "$SID" ]]; then
    SF=$(_ic_state_file "$SID")
    STATE=$(_ic_read_state "$SF")
    NEW_STATE=$(echo "$STATE" | jq '.syntax_errors = (.syntax_errors + 1)')
    _ic_write_state "$SF" "$NEW_STATE"
  fi
  # Truncate to 300 chars for clean output
  ERR_SHORT="${ERR:0:300}"
  jq -n --arg msg "Syntax error in $FP: $ERR_SHORT" '{"additionalContext": $msg}'
fi
