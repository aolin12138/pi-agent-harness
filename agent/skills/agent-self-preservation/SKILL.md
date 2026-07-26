---
name: agent-self-preservation
description: "Operational safety skill for the agent itself. Use when killing processes, restarting pi, or making changes that affect pi's ability to launch. Defines guardrails that protect pi from killing itself, ensures changes are verified loadable before requesting a restart, and provides recovery procedures when pi fails to start. Hard rules from AGENTS.md point here for depth."
metadata:
  short-description: Don't kill pi by accident; verify changes load before restart
---

# Agent self-preservation

The agent runs inside pi. Pi is a node process. Operations the agent takes on processes and files can destroy the agent's own host. This skill encodes the depth behind the hard rules in AGENTS.md so the agent can survive its own work.

These rules are **always-on** via AGENTS.md (hard one-liners). The depth here is read on-demand when about to perform a kill or suggest a restart.

## When to load this skill

- Before any process-killing operation (any `kill`, `pkill`, `taskkill`, `Stop-Process`, `wmic`, `End-Process`).
- Before any change to files in `~/.pi/agent/` that may require pi to be restarted.
- Before any change to a pi extension in `~/.pi/agent/extensions/` or `~/.pi/pi-web/extensions/`.
- After a pi crash or restart failure, to find recovery procedures.

## Rule 1 — Never kill the pi process

Pi is a node process. Any command that targets node-by-name will catch pi. **Never use bare name-based killers.**

### Forbidden (never use these without filtering)

| Platform | Command | Why forbidden |
|---|---|---|
| All | `pkill node` | kills every node process including pi |
| All | `killall node` | same |
| Windows | `taskkill /f /im node.exe` | same |
| Windows | `Stop-Process -Name node` | same |
| All | `kill %1` / `kill %2` | job control; kills whatever happens to be that job |

### Required pattern — PID-based, identified by parent / port / command line

**On Windows (PowerShell):**

```powershell
# Identify by listening port first (most common case)
$pid = (Get-NetTCPConnection -LocalPort 3099 -ErrorAction SilentlyContinue).OwningProcess
if ($pid) { Stop-Process -Id $pid -Force }

# Or identify by command-line contains
$proc = Get-CimInstance Win32_Process |
        Where-Object { $_.CommandLine -like "*server/index.mjs*" -and $_.Name -eq "node.exe" }
if ($proc) { Stop-Process -Id $proc.ProcessId -Force }

# Verify pi is NOT in the result before killing
# pi command line typically contains "pi-coding-agent" or runs from
# C:\Users\User\AppData\Roaming\npm\node_modules\@earendil-works\pi-coding-agent
```

**On Unix/WSL:**

```bash
# By port
lsof -ti:3099 | xargs -r kill -TERM

# By command-line match (verify match excludes pi)
ps aux | grep "server/index.mjs" | grep -v grep
# Take the PID from the result, then:
kill -TERM <pid>
```

### Safety checklist before any kill

1. **Run a dry inspection first.** `Get-Process` or `ps` to list candidates with their command lines.
2. **Verify the candidate is NOT pi.** Pi's command line typically contains `pi-coding-agent` or runs from the global npm install location.
3. **Use TERM before KILL.** `kill -TERM` (SIGTERM) gives a chance to clean up; `-KILL` / `-Force` only after TERM fails to land in 3-5 seconds.
4. **One PID at a time.** Never pipe a list of PIDs into kill without printing them first.

## Rule 2 — Never restart pi autonomously

The agent does not restart pi itself. If a change requires a restart:

1. **Inform the user the change requires a restart.**
2. **Tell the user what to do** (typically: type `/reload` for hot-reloadable resources, or quit and relaunch for extensions or settings).
3. **Verify the change is safe to load before asking** (Rule 3 below).

The agent must never run a command that would terminate the current pi session (e.g. `process.exit`, killing the pi process, deleting files pi has open).

## Rule 3 — Verify before suggesting restart (pre-launch check)

A bricked pi is the worst failure mode — the user can't even see the conversation to ask for help. Before suggesting a restart for any change:

### What kind of change, what to verify

| Change type | Dry-load verification |
|---|---|
| JS/TS extension in `~/.pi/agent/extensions/` | `node -e "require('./<path>')"` — must exit 0. Catches syntax errors, missing imports, top-level throws. |
| Compiled TS extension | Run `tsc --noEmit` (or `npx tsc --noEmit`) on the file before suggesting restart. |
| `settings.json`, `auth.json`, `models.json` | `node -e "JSON.parse(require('fs').readFileSync('<path>','utf-8'))"` — must exit 0. |
| `AGENTS.md`, `APPEND_SYSTEM.md`, `SYSTEM.md` | Markdown — can't syntax-check, but: byte-check for unmatched code fences, oversized line count (warn if >300 lines), valid frontmatter if present. |
| New skill `SKILL.md` | Valid YAML frontmatter parse + presence of `name` and `description` fields. |
| New `workflows/*.yaml` | YAML parse via `node -e "require('js-yaml').load(...)"` or equivalent. |
| Extension directory restructure | Verify the extension's manifest still resolves; `node -e "require('./<ext>/index.js')"`. |

### Hot-reload first if possible

Many resources support `/reload` and don't need a full pi restart. **Always prefer `/reload` over restart if the resource is hot-reloadable.** From pi changelog: AGENTS.md, SYSTEM.md, APPEND_SYSTEM.md, prompt templates, skills, themes, and extensions are all hot-reloadable. Settings (`settings.json`) typically need a full restart.

### What to tell the user

After dry-load passes, the message to the user is:

> Change is loadable (dry-loaded `<path>` and exit code was 0). Try `/reload` first — that handles AGENTS.md/skills/extensions without restart. If `/reload` reports an error or the change is to settings, you'll need to quit and relaunch pi. If pi fails to start, see recovery below.

## Rule 4 — Recovery procedure when pi won't launch

If the user reports pi failing to launch after a restart you suggested, immediately:

1. **Ask for the exact error text.** Don't guess from symptoms.
2. **The most likely cause is the last file you touched.** Get the user to either:
   - Revert it: `git diff HEAD <file>` to see the change, `git checkout <file>` to revert (only if file is tracked).
   - Move it out of pi's discovery path temporarily: `mv ~/.pi/agent/extensions/<broken> ~/tmp/`.
3. **Common error patterns and their fixes:**

| Error pattern | Likely cause | Fix |
|---|---|---|
| `SyntaxError` in an extension | Bad JS/TS edit | `mv` the extension out, ask user to relaunch, debug separately |
| `Cannot find module 'X'` | Missing dependency in an extension | `cd <ext> && npm install`, then relaunch |
| `Unexpected token` in JSON | Bad settings.json edit | Restore from backup at `~/.pi/backups/` if it exists; otherwise hand-fix |
| Hang during startup, no error | Likely an extension's top-level `await` blocking | `mv` extensions out one at a time until it starts |
| `YAML parse error` in a workflow | Bad workflow edit | `mv` the workflow out, relaunch |

4. **After recovery, the dry-load step gets reinforced.** Each recovery incident is evidence that the verification step caught a real failure mode or missed one; log it in the journal as a Lesson and update this skill's verification table if a new kind of failure was found.

## Cross-references

- `~/.pi/agent/AGENTS.md` — hard one-line rules that point here for depth
- `~/.pi/agent/skills/debugging-protocol/SKILL.md` — used in conjunction when diagnosing why a load failed
- `~/.pi/llm-wiki/built/run-journal.md` — log recovery incidents as Attempts; promote new failure patterns to this skill
- `~/.pi/backups/` — pi's automatic file-state backups (if enabled in settings)
