---
name: debugging-protocol
description: >
  Bug fixing and debugging framework. Use when asked to fix a bug, debug an error,
  investigate a crash, resolve broken behavior, or find why something isn't working.
  Covers feedback loop construction, root cause analysis, and regression testing.
---

# Debugging Protocol

A systematic framework for finding and fixing bugs. The central principle:
debugging is not about staring at code — it's about constructing a feedback
loop that reliably signals whether you're getting closer or further from
the cause.

## Before you start debugging — recognize these traps

Every debugger is vulnerable to the same failure modes. Name them so you can
notice them in your own reasoning:

- **Assumption-driven.** You assumed the input shape, the API contract, or the
data format without checking. Three hours of patching a parser that assumed JSON
when the actual input was plain text. Check one real example before writing a
single line of parser code.

- **Symptom-chasing.** You made a third edit to the same function without the
failure changing. You're patching, not investigating. Stop. Read the data flowing
through the failing point. Ask: "what does the ACTUAL input look like?"

- **Single-hypothesis tunnel.** Your first guess was too plausible. You haven't
generated alternatives. A second hypothesis costs nothing and doubles your chance
of being right.

- **Fix-by-fallback.** You added a timeout, retry, default-empty, or silent catch
because you don't understand why something hangs or fails. That's not a fix —
it's evidence that you don't know the root cause. Remove it and trace instead.

- **Dismissing counter-evidence.** The user said something worked before; you
assumed they misremembered. User corrections are data, not opinion. Investigate
them before dismissing.

- **Trial-by-reload.** Your test loop is the full deploy cycle. A 30-second local
script would give the same signal 40x faster. Invest in a faster loop the moment
you realize you'll need more than one attempt.

If you recognize any of these in yourself: name it aloud. Then either step back
and trace, or spawn an advisor to trace with you.

See also: `patterns/symptom-chasing-antipattern.md` — a two-hour session where
an agent hit every one of these traps in sequence, and the user's intervention
breaking the cycle.

## The core insight

**Build the feedback loop first. Everything else is mechanical.**

If you have a fast, deterministic, agent-runnable pass/fail signal for the
bug, you will find the cause — bisection, hypothesis-testing, and
instrumentation all just consume that signal. If you don't have one, no
amount of code reading will save you.

The feedback loop is the product. Treat it as such: make it faster, make
the signal sharper, make it more deterministic. A 30-second flaky loop is
barely better than no loop. A 2-second deterministic loop is a debugging
superpower.

**The smallest feedback loop that would have caught today's session:**
```bash
grep '"toolName":"task_' session.jsonl | tail -3
```
One command, 30 seconds, would have revealed the plain-text format and
saved two hours of patching. Before you write a parser, read one real example
of the input.

## Constructing the feedback loop

The goal is a signal that answers: "is the bug still present?" — fast,
reliably, and without human intervention. Try these methods in roughly
increasing cost order:

1. **Failing test** — at whatever seam reaches the bug: unit, integration, or E2E.
2. **HTTP script** — curl or fetch against a running dev server with known inputs.
3. **CLI invocation** — run with fixture input, diff stdout against expected output.
4. **Headless browser** — Playwright/Puppeteer script that drives the UI and asserts on DOM/console/network.
5. **Replay captured trace** — save a real request/payload/event log; replay through the code path in isolation.
6. **Throwaway harness** — minimal subset of the system (one service, mocked deps) that exercises the bug path.
7. **Property / fuzz loop** — for "sometimes wrong output": run 1000 random inputs, find the failure pattern.
8. **Bisection harness** — for regressions: automate "boot at state X, check" for git bisect.
9. **Differential loop** — run same input through old vs new version, diff outputs.
10. **Manual script** — last resort. If a human must click, give them a structured script. Capture output.

**Iterate on the loop.** Once you have a basic loop, ask: can I make it faster?
Sharper? More deterministic? Pin time, seed RNG, isolate filesystem.

### Non-deterministic bugs

The goal is not a clean repro but a **higher reproduction rate.** Loop the
trigger 100×, parallelize, add stress, narrow timing windows. A 50%-flake
bug is debuggable; 1% is not — keep raising the rate.

### When a loop genuinely can't be built

Stop. Say so explicitly. List what you tried. Ask the user for: access to
the reproducing environment, a captured artifact (HAR file, log dump, core
dump), or permission to add temporary instrumentation. Do not proceed to
hypothesis without a loop.

## The debugging discipline

### Phase 1 — Understand expected behavior

Before touching code, establish what SHOULD happen at each step:

**Trace the workflow step-by-step.** For every step in the chain from trigger
to outcome, write:

```
Step 1: [what triggers] → Expected: [what should happen] → Actual: [what happens] → Gap: [yes/no]
Step 2: [next step]     → Expected: [what should happen] → Actual: [what happens] → Gap: [yes/no]
...
Step N: [final output]  → Expected: [what user sees]    → Actual: [what user sees]  → Gap: [yes/no]
```

**The fix goes at the first step with a gap.** Everything before that step is
working fine. Everything after might be broken too, but you can't know until
the first gap is closed.

**Concrete example (from a real session):**

```
BUG: Tasks created via task_create don't appear in web task panel.

Step 1: Agent calls task_create       → Expected: pi creates task entry     → Actual: task entry in session ✓  → Gap: no
Step 2: tool_execution_end fires      → Expected: event has result data     → Actual: event fires with result ✓  → Gap: no
Step 3: updateTasks(event.result)     → Expected: parses result, adds to Map → Actual: Map stays empty ✗          → Gap: YES
Step 4: broadcastToWeb sends tasks    → Expected: clients get task list     → Actual: sends empty array ✗         → Gap: YES
Step 5: Web renders TaskBoard         → Expected: tasks visible in sidebar  → Actual: "No tasks" ✗               → Gap: YES

First gap: Step 3. Fix that. Steps 4-5 might auto-resolve.

ROOT CAUSE: Step 3 assumed result is JSON. Actual result is plain text.
```

This is not the same as "read the error message." It means understanding
the workflow, the data flow, and the expected outcome at each step.

### Phase 2 — Build the feedback loop

Construct the pass/fail signal described above. This is the most important
phase. Be creative. Refuse to give up. A good loop is 90% of the fix.

### Phase 3 — Reproduce

Run the loop. Watch the bug appear. Confirm:

- The failure matches what the USER described, not a different nearby failure
- The failure is reproducible (or has high enough reproduction rate)
- You've captured the exact symptom so later phases can verify the fix

### Phase 4 — Hypothesise

Generate **3-5 ranked hypotheses** before testing any. Single-hypothesis
generation anchors on the first plausible idea and blinds you to alternatives.

Each hypothesis must be **falsifiable** — state the prediction it makes:

> "If X is the cause, then changing Y will make the bug disappear,
> and changing Z will make it worse."

If you can't state a prediction, the hypothesis is a vibe — discard or sharpen it.

**Show the ranked list to the user before testing.** They often have domain
knowledge that instantly re-ranks. Cheap checkpoint, big time saver.

### Phase 5 — Instrument

Test hypotheses one at a time. **Change one variable at a time.** If you
change three things and the bug disappears, you've learned nothing about
which one mattered.

**After each change: observe.** Did the output shift in the direction your
hypothesis predicted? If yes, you're on the right path. If no, you learned
something — feed it back into a revised hypothesis before the next change.

Tool preference:
1. Debugger / REPL — one breakpoint beats ten logs
2. Targeted logs at the boundaries that distinguish hypotheses
3. Never "log everything and grep"

**Tag every debug log** with a unique prefix (e.g., `[DEBUG-a4f2]`). Cleanup
becomes a single grep. Untagged logs survive; tagged logs die.

### Phase 6 — Fix and regression-test

1. Turn the minimized repro into a regression test at the correct seam.
2. Watch it fail (proves the test catches the bug).
3. Apply the fix.
4. Watch it pass.
5. Re-run the original feedback loop against the un-minimized scenario.
6. **Re-trace from step 1.** Every gap must now show "no." Fixing one step
   can expose the next — the first gap hid everything after it.
7. **Capture what you learned.** A bug caused by an assumption is a signal.
   Before declaring done: would a future agent on this project benefit from
   knowing the real data shape, API contract, or behavior you just discovered?
   If yes: project wiki, code comment, or session memory.

**A note on test seams:** Only write a regression test if there's a correct
seam — one where the test exercises the real bug pattern as it occurs at
the call site. If no correct seam exists (unit test can't replicate the
chain that triggered the bug), that itself is a finding. Note it — the
architecture is preventing the bug from being locked down.

### Phase 7 — Cleanup

- [ ] Original repro no longer reproduces
- [ ] Regression test passes (or absence of seam documented)
- [ ] All `[DEBUG-...]` instrumentation removed
- [ ] Throwaway files deleted
- [ ] Wrong assumption documented (wiki, code comment, or memory)
- [ ] Root cause stated in commit message — so the next debugger learns

### After the fix

Ask: what would have prevented this bug? If the answer involves architectural
change (no good test seam, tangled callers, hidden coupling), flag it. The
bug is fixed — but the conditions that created it may still exist.

## Integration with the orchestrator

This protocol is invoked during the **Understanding phase** for bugfix tasks.
The orchestrator should:

1. Use the bug-reproduction scout to construct the feedback loop and trace
   the execution path (Phase 1-3)
2. Synthesize scout findings into hypotheses (Phase 4)
3. Present ranked hypotheses to the user for domain-knowledge input
4. Proceed to fix only after hypothesis is confirmed (Phase 5-7)

The feedback loop becomes the verification metric for the bugfix — the task
is done when the loop passes and the regression test exists.

## Related frameworks

- `orchestrator-guidance` — the orchestrator invokes this during Understanding
  phase for bugfix tasks
- `verification-protocol` — the feedback loop becomes the correctness metric
- `karpathy-guidelines` — goal-driven execution ("write a test that reproduces
  it, then make it pass") is the same principle applied concretely
