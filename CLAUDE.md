# Intercheck

Code quality guards and session health monitoring via PostToolUse hooks.

## Hooks

- `hooks/context-monitor.sh` — Tracks context pressure (call count + time decay + token estimate). Warns at Yellow/Orange/Red thresholds. Auto-checkpoints at Red.
- `hooks/syntax-check.sh` — Validates Python, Shell, JSON, TOML, YAML, Go, TS/JS after every Edit/Write. Reports errors via additionalContext.
- `hooks/auto-format.sh` — Runs formatters (ruff, shfmt, gofmt, jq, prettier) after edits. Silent, best-effort.

## State

Session state stored at `/tmp/intercheck-${SESSION_ID}.json`. Contains call count, pressure score, estimated tokens, syntax error count, and format run count.

## Skill

- `/intercheck:status` — Show current session health dashboard.

## Pressure Model

- Each tool call adds 1.0 (or 1.5 for Read/Grep/Task/WebFetch/WebSearch)
- Pressure decays 0.5 per 10 minutes of inactivity
- Token estimate: cumulative tool output length / 4
- Thresholds: Green < 60, Yellow 60+, Orange 90+, Red 120+ (or token equivalents at 150k/180k/200k)
