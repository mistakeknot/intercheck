---
name: status
description: Show code quality metrics for this session
---

# Intercheck Status

Show the current session's code quality metrics from intercheck's hooks.

## Instructions

Read the session state file at `/tmp/intercheck-${SESSION_ID}.json` where `SESSION_ID` is the current session's ID.

If the file doesn't exist, report "No intercheck data for this session (hooks may not be active)."

If the file exists, parse the JSON and display:

```
Code Quality
──────────────────────────────
Syntax errors:     {syntax_errors}
Auto-formats:      {format_runs}
──────────────────────────────
```

For session pressure and token monitoring, use `/interpulse:status`.
