# Intercheck

Code quality guards via PostToolUse hooks. For session pressure monitoring, see interpulse.

## Hooks

- `hooks/syntax-check.sh` — Validates Python, Shell, JSON, TOML, YAML, Go, TS/JS after every Edit/Write. Reports errors via additionalContext.
- `hooks/auto-format.sh` — Runs formatters (ruff, shfmt, gofmt, jq, prettier) after edits. Silent, best-effort.

## State

Session state stored at `/tmp/intercheck-${SESSION_ID}.json`. Contains syntax error count and format run count.

## Skill

- `/intercheck:quality` — Show code quality metrics for this session.
