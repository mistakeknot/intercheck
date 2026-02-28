# intercheck — Vision and Philosophy

**Version:** 0.2.0
**Last updated:** 2026-02-28

## What intercheck Is

intercheck is a pair of PostToolUse hooks that fire after every file edit. The first hook
validates syntax against the language's native parser — `py_compile` for Python, `bash -n`
for shell, `json.load` for JSON, `go vet` for Go, `node --check` for TypeScript and
JavaScript. The second hook runs the language's canonical formatter — ruff, shfmt, gofmt,
jq, prettier — and rewrites the file in place. Both hooks track their activity in a
session-scoped state file at `/tmp/intercheck-${SESSION_ID}.json`. The `/intercheck:status`
skill surfaces those counters on demand.

The design contract is: silence means clean. Hooks produce no output when everything is
correct. When syntax is broken, the error appears in `additionalContext` immediately,
before the agent proceeds to the next edit.

## Why This Exists

Syntax errors that survive into later edits compound. An agent that writes a broken import
on line 3, then adds a function on line 40, then a test on line 80, has three layers of
work to unwind when the parse failure surfaces. intercheck closes that loop at the earliest
possible moment — the PostToolUse boundary, before any downstream action runs. This is the
cheapest quality gate in the stack: no network calls, no spawned processes beyond what's
already installed, no configuration required.

## Design Principles

1. **Silence is the success signal.** Hooks that always output something add noise.
   intercheck outputs nothing on success. When the additionalContext channel is quiet,
   the session knows every edited file parsed cleanly.

2. **Fail-open on missing tools.** If `gofmt` isn't installed, Go files are silently
   skipped. If `prettier` isn't available locally, TypeScript files are left as-is. No
   hard failure, no session interruption. The plugin degrades gracefully to whatever
   toolchain the environment provides.

3. **Every edit produces a receipt.** The session state JSON is a durable artifact:
   syntax errors caught, auto-formats applied. These counters are evidence — auditable,
   observable, replayable — not ephemeral console output.

4. **Mechanism, not policy.** intercheck enforces that edited files parse. It does not
   enforce style rules, complexity limits, or project-specific conventions. Those are
   policy decisions owned by the project or by companion plugins.

5. **One layer of a stack, not the whole stack.** Syntax validation is the first gate.
   Tests (intertest), linting (interflux), and coverage analysis belong in later gates.
   intercheck does not try to absorb them.

## Scope

**Does:**
- Validate syntax for Python, Shell, JSON, TOML, YAML, Go, TypeScript, JavaScript
- Auto-format using the language's canonical formatter when available
- Track error counts and format runs per session
- Surface errors immediately via additionalContext

**Does not:**
- Run tests or check coverage
- Enforce style beyond what the formatter applies
- Validate YAML/TOML against a schema
- Type-check (no mypy, no tsc --noEmit)
- Require any project configuration to function

## Direction

- Expose session quality counters to interwatch as a watchable signal, enabling
  dashboard-level visibility across multiple concurrent sessions.
- Add configurable error thresholds: if syntax_errors exceeds N in a session, surface
  a session-level warning via the status skill.
- Expand auto-format coverage as formatters stabilize (e.g., `taplo` for TOML,
  `yamlfmt` for YAML) without changing the fail-open contract.
