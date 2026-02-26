#!/usr/bin/env bash
# Shared library for intercheck hooks.
#
# Provides:
#   _ic_session_id     — extract session_id from stdin JSON
#   _ic_state_file     — path to session state file
#   _ic_read_state     — read state JSON (or default)
#   _ic_write_state    — write state JSON
#   _ic_file_path      — extract file path from tool input JSON
#   _ic_detect_lang    — detect language from file extension

[[ -n "${_LIB_INTERCHECK_LOADED:-}" ]] && return 0
_LIB_INTERCHECK_LOADED=1

_ic_session_id() {
  echo "$1" | jq -r '.session_id // empty' 2>/dev/null
}

_ic_state_file() {
  local sid="$1"
  echo "/tmp/intercheck-${sid}.json"
}

_ic_read_state() {
  local sf="$1"
  if [[ -f "$sf" ]]; then
    cat "$sf"
  else
    echo '{"syntax_errors":0,"format_runs":0}'
  fi
}

_ic_write_state() {
  local sf="$1" state="$2"
  echo "$state" > "$sf"
}

_ic_file_path() {
  local json="$1"
  echo "$json" | jq -r '.tool_input.file_path // empty' 2>/dev/null
}

_ic_detect_lang() {
  local fp="$1"
  case "$fp" in
    *.py)           echo "python" ;;
    *.sh|*.bash)    echo "shell" ;;
    *.json)         echo "json" ;;
    *.toml)         echo "toml" ;;
    *.yaml|*.yml)   echo "yaml" ;;
    *.go)           echo "go" ;;
    *.ts|*.tsx)     echo "typescript" ;;
    *.js|*.jsx)     echo "javascript" ;;
    *)              echo "unknown" ;;
  esac
}
