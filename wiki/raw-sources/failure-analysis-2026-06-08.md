# Failure Analysis Report — 2026-06-08 pi-web Debugging Session

> **You asked**: "the agent kept failing on the task for askpanel and taskpanel, why was it failing? what's the failing pattern? what did the agent do wrong? and then i asked it to do something, what happened there? after that why did agent worked and fixed it in oneshot?"

---

## Timeline of the failure

### Phase 1 — Symptom chasing on the Task panel (≈ 2 hours)

The agent ran through **at least seven different "fixes"** before finding the real bug:

| # | Theory | Action | Result |
|---|---|---|---|
| 1 | "Frontend isn't rendering" | Tweaked `MessageList`/`TaskBoard` keys | Tasks Map still empty |
| 2 | "Tool execution events missing" | Added subscription isolation | Events fired, Map still empty |
| 3 | "Polling loop isn't scanning entries" | Scanned `cachedEntries` for task results | Same parser, same nothing |
| 4 | "Task args not captured at start" | Added `pendingTaskArgs` map | Still empty |
| 5 | "Map not session-scoped" | Added `getTasksFor(session)` | Same data parsing bug remained |
| 6 | "Tasks broadcast missing after rebuild" | Added `broadcastToWeb` | Now broadcasts an empty array |
| 7 | "Regex tweak 1, 2, 3…" | Modified `parseTaskTextResult` multiple times | Different broken outputs |

Each `/reload` round took 2–5 minutes including the user's manual restart. You burned a **lot** of these.

### Phase 2 — Symptom chasing on the Ask panel

Same pattern:

- Add a timeout fallback (you correctly rejected this: *"no not timeout, that's the worst way to fix that"*).
- Try to `bind(ctx.ui)` the original `custom` — `undefined` at patch time.
- Wrap in a Proxy — same problem, `Reflect.get` returns `undefined`.
- Defer capture to first call — but the override is already in place.
- Forward keystrokes from web to the captured TUI widget — never reached, because the original `custom` was never called.

### Phase 3 — The turning point

You said:

> "take a step back, really investigate on the code, what was our logic?
> is the logic correct? are we making any assumptions that could be wrong?
> if the logic is correct, trace the workflow, see where it went wrong
> exactly. did it not sync the tasks? is the hook not working? is the
> web expecting something else? how does the web receives the task
> information and ask event?"

This forced the agent to do four things it had been skipping:

1. **Read the full server file**, not just the symptom site.
2. **Read the actual session JSONL** to see what `task_create` really returns.
3. **Test the regex** on real strings in a node REPL.
4. **Form one hypothesis** that explained ALL the symptoms, not just the latest.

Within minutes the agent found:

- **Bug A** — `task_create` results are *plain text* (`"Task #42 created successfully: subject"`), not JSON. The old `updateTasks` only handled JSON, so it silently dropped everything.
- **Bug B** — once `parseTaskTextResult` was added, the regex `(deleted)\.?:?\s*(.*)$` used `\s*` which **matches `\n`**. With `g` flag and greedy `.*`, the first match consumed all subsequent lines into capture group 3. Only every second delete operation was registered, which is why the prior "fix" *appeared* to half-work and confused the diagnosis.

A single regex change (`\s*(.*)` → `[ \t]*(.*?))?$` with `gm` flag + the `Operation \d+:` prefix) fixed all symptoms at once.

---

## What the agent did wrong — the failure pattern

### 1. Assumption-driven coding

The agent **assumed** task tools return `{id, subject, status}` JSON. It never opened a session entry to verify before writing the parser. The shape was actually plain text the whole time. Several hours of work cascaded from this unchecked assumption.

### 2. Patch-don't-investigate loop

When attempt N failed, the agent reached for attempt N+1 in the same area instead of stepping out and asking *"is my mental model of the data correct?"*. Each new patch was added on top of broken parsing, hiding the real issue under more layers.

### 3. Trial via `/reload` instead of local verification

The feedback loop was: edit → `npm run build` → ask you to `/reload` → run Playwright → look at result. That's a slow, expensive loop. A 5-line node script testing the regex against real session text would have exposed both bugs in 30 seconds.

### 4. Local fixes copied to four call sites

The same broken `parseJsonText` was used in `updateTasks`, the polling loop, the session-start rebuild, and the event handler. The agent updated each independently, each time keeping the bug. A single shared `parseTaskTextResult` would have surfaced the issue earlier.

### 5. Ignoring your counter-evidence

You said multiple times that the CLI ask panel had been working before. The agent treated this as wishful memory and kept claiming the architecture didn't allow it. The honest answer (eventually documented) is: *pi-core installs `ctx.ui.custom` AFTER `session_start`, so any extension that overrides `custom` overwrites `undefined` and the default never installs* — but that conclusion required actually reading `examples/extensions/question.ts` and `pi-ask/src/ui/controller.ts`, not guessing.

### 6. Adding "fallbacks" instead of solving

The 5-minute timeout you correctly rejected was a symptom of the same failure mode: *I don't know why this hangs, so I'll add a band-aid timeout.* That's giving up on root-cause analysis dressed as a feature.

---

## What you did that broke the cycle

Your message was effective because it was a **process intervention**, not a hint at the answer:

- "Take a step back" — forced exit from the patch loop.
- "What was our logic? Is the logic correct?" — forced the agent to re-derive the design, not defend it.
- "Are we making any assumptions that could be wrong?" — forced explicit listing of assumptions, where the JSON-shape assumption was sitting unexamined.
- "Trace the workflow, see where it went wrong exactly" — forced a step-by-step data-flow trace from `task_create` call → session entry → cache → `updateTasks` → Map → broadcast → browser.
- "How does the web receive the task information?" — forced reading the *whole* path, not just one end.

You didn't tell the agent the answer. You told it *to do the analytical step it had been skipping*. That single message is what produced the one-shot fix.

---

## Why the fix was one-shot after that

Because the trace **revealed the real problem**:

- Looking at one real `task_create` toolResult showed plain text, not JSON.
- Looking at the regex with a real multi-line string showed `\s*` consuming `\n`.
- These two facts explain **every** symptom seen up to that point:
  - Empty tasks Map → JSON parse always returns `null`.
  - Alternating tasks deleted → greedy regex skipping every second line.
  - Wrong status after rebuild → flat args overwriting merge with empty subject from regex.

One regex change, one Operation-prefix addition, one merge-don't-clear in rebuild = done.

The Ask-panel CLI mirror could *not* be fixed in one shot because the limitation is genuinely in pi-core's lifecycle (lazy install of `ctx.ui.custom` after `session_start`). The agent eventually got there but only after the same investigative path: reading `examples/extensions/question.ts` to see the callback signature, then proving via Proxy that `Reflect.get(ctx.ui, "custom")` returns `undefined` at patch time. That conclusion is now in `references/pi-ctx-ui-custom-lifecycle.md` so future agents skip the wasted attempts.

---

## What was ingested into the wiki

| File | Purpose |
|---|---|
| `C:/Users/User/.pi/pi-web/.wiki/bugfixes-2026-06-08.md` | The six concrete bugs and their fixes |
| `references/pi-ctx-ui-custom-lifecycle.md` | The pi-core limitation that blocks CLI+web mirroring |
| ~~`patterns/symptom-chasing-antipattern.md`~~ *(deleted; folded into `debugging-protocol` skill)* | The behavioural anti-pattern with concrete remedies |
| `~/.pi/user/memory/sessions/2026-06-07.md` | Session summary appended |
| `~/.pi/llm-wiki/log.md` | Wiki changelog entry |
| `~/.pi/llm-wiki/index.md` | Added Patterns section + new entries |

---

## Concrete rules the agent should now follow

These were written into `patterns/symptom-chasing-antipattern.md` (now folded into the `debugging-protocol` skill) so sessions would load them:

1. **Before writing any parser, grep the real input format.** One `grep | tail -3` saves hours.
2. **Test regexes with a 5-line node script against real strings**, before deploying.
3. **When stuck twice on the same area, change strategy**: stop patching, start tracing.
4. **Treat user counter-evidence as data, not opinion.** "X was working before" means investigate, not dismiss.
5. **Never add a timeout, retry, or fallback as a fix.** It's evidence that root cause is unknown.
6. **One hypothesis must explain ALL symptoms.** Partial explanations hide the real bug.

---

## Want me to also…?

- Add an explicit pre-commit hook on `~/.pi/pi-web/` to run regex tests on `parseTaskTextResult` against fixture session strings? (Would catch regressions of bug B.)
- Open a tracking note for the pi-core change request (expose `ctx.ui.custom` before `session_start` or add `onBeforeCustom` hook)?

Tell me and I'll do it.
