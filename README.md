# intercheck

Code quality guards and session health monitoring for Claude Code.

## What This Does

Long coding sessions accumulate pressure — context grows, small errors compound, and formatting drift becomes invisible. intercheck runs three PostToolUse hooks that catch problems as they happen rather than letting them pile up.

**Context pressure tracking** scores each tool call (+1.0 for normal calls, +1.5 for heavy tools like Task), decays 0.5 per 10 minutes of inactivity, and escalates through Yellow/Orange/Red thresholds. At Red (120+), it triggers an auto-checkpoint so you don't lose work to context exhaustion.

**Syntax validation** runs after every Edit and Write — Python, Shell, JSON, TOML, YAML, Go, TypeScript, and JavaScript. Catches the kind of malformed output that's easy to miss when you're moving fast.

**Auto-formatting** silently applies ruff, shfmt, gofmt, jq, or prettier after edits. No prompting, no ceremony — just consistent formatting without thinking about it.

## Installation

```bash
/plugin install intercheck
```

## Usage

The hooks run automatically. To check session health manually:

```
/intercheck:status
```

Shows a dashboard with current pressure score, tool call count, estimated token usage, and threshold status.

## Architecture

```
hooks/
  context-monitor.sh    PostToolUse — pressure tracking
  syntax-check.sh       PostToolUse — validation after Edit/Write
  auto-format.sh        PostToolUse — silent formatting
skills/
  status/SKILL.md       Session health dashboard
```

State lives in `/tmp/intercheck-${SESSION_ID}.json` — ephemeral by design.
