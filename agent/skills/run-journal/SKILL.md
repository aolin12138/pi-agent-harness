---
name: run-journal
description: "Diagnostic journal pattern for non-trivial tasks. Externalises working memory: user request verbatim, success criteria designed via verification-protocol, smallest task decomposition via karpathy-guidelines, hypothesis-and-attempt log via debugging-protocol. Use whenever a task is expected to take more than ~5 tool calls, has a debugging component, or the user has reformulated the request 2+ times. Replaces silent in-chat reasoning with an editable file that survives the long debugging tail."
metadata:
  short-description: Live diagnostic journal for non-trivial tasks
---

# Run Journal

A run journal is a live markdown file the agent maintains during a non-trivial task. It externalises the agent's working memory — the user's actual request, the agreed success criteria, the smallest sensible task decomposition, the current hypothesis, and a per-attempt log of what was tested with what result.

**The journal is for both the agent and the user.** It is not an internal agent diary. The user reads it to verify alignment, watch progress, and catch drift early. The user may also *edit* it — corrections to the verbatim request, refinements to success criteria, additional evidence, or direct notes — and the agent must re-read before each subsequent tool call to pick up those edits.

Because the journal is user-facing, three things matter that wouldn't matter for an agent-only diary:

1. **Status visible at the top.** The user must be able to open the file and see "Awaiting your confirmation on criteria" or "In progress, Attempt 4 FAIL" without scrolling.
2. **Plain-language summary alongside structured fields.** Agent-jargon (`Verdict: INCONCLUSIVE`) is fine but must be paired with a one-line plain-language restatement so a quick scan is enough.
3. **One canonical location for the active journal.** `~/.pi/runs/ACTIVE.md` always contains the path of the currently active journal and a status snapshot. The user never has to grep timestamps.

The journal exists because skills-in-context decay over a long session. Once a framework has been "applied", the agent tends to forget which phase it's in and stop applying it. A file the agent must edit at each step — and that the user can correct at any step — is much harder to drift away from than a paragraph the agent skimmed an hour ago. See `~/.pi/llm-wiki/patterns/framework-decay-under-iteration.md` for the failure mode this skill is designed to defeat.

The journal is **not** the task list. The task list tracks *what to do*. The journal tracks *what I currently believe, what I have just learned, and why I think the work is or isn't done*.

## When to start a journal

Start one when:

- The task is expected to take more than ~5 tool calls.
- The task has a debugging component (something is broken and the cause is not obvious).
- The user has reformulated the request 2+ times — alignment is at risk.
- A previous run journal exists for the same project under `~/.pi/llm-wiki/projects/<proj>/runs/` — read it first.

Skip when:

- One-shot lookup, trivial edit, or pure chat.
- The task is fully scripted (e.g. "run these three commands").

## Where the journal lives

- **During the run:** `~/.pi/runs/<YYYY-MM-DD>-<slug>/journal.md`
- **Always-current pointer (for the user):** `~/.pi/runs/ACTIVE.md` — contains the absolute path of the active journal plus a status snapshot (last updated timestamp, current section in progress, criteria met/total, last verdict). Updated by the agent on every status change. If there is no active task, this file says `no active journal`.
- **At task end (archive):** `~/.pi/llm-wiki/projects/<project>/runs/<YYYY-MM-DD>-<slug>.md`. The active journal is moved here, and `ACTIVE.md` reverts to `no active journal`.
- **At session end (promotion):** the Lessons section is reviewed; recurring failure patterns get promoted to `~/.pi/llm-wiki/patterns/`.

## How the user reads and edits the journal

The user is a first-class reader. They may:

- Open `~/.pi/runs/ACTIVE.md` to see what's live without asking the agent.
- Open the active journal directly to scan the status header and Attempts log.
- Edit any section. Common edits: fixing the verbatim user-request quote, sharpening a success criterion, adding evidence to a hypothesis, leaving notes in the User notes section.

Agent obligations to support this:

- **Re-read the journal before every tool call** when in an active task. User edits between tool calls are common and must be honoured.
- **Tell the user the journal path on creation** and at every alignment gate: "Journal at `<path>`, please confirm Section 1 (verbatim request) matches what you asked for."
- **Status header must be updated before any tool call** that changes state (new attempt started, criterion met, hypothesis shifted, halt triggered). Stale status is worse than no status.
- **Never silently overwrite a user edit.** If the agent and the user have edited the same section, the agent stops and asks.

## Construction rules (per section)

Each section of the journal is constructed by reading the matching engineering skill first. The skill teaches the *how*; the journal records the *what*. Do not write a section before reading its sourcing skill.

### 1. User request — verbatim

- Quote the user's exact words. No paraphrase in this block.
- Below the quote, write a one-line restatement and tag it explicitly as `agent paraphrase:`.
- **Alignment gate:** after writing this section, post the journal path to the user and ask them to confirm the verbatim quote matches what they asked for. Do not start work on a misread request.
- If your paraphrase shifts meaning, or you cannot write it without changing terms, halt and ask before the next tool call.

### 2. Success criteria — from `verification-protocol`

- Read `~/.pi/agent/skills/verification-protocol/SKILL.md` before writing this section.
- For each of the six dimensions that applies — correctness, completeness, quality, security, regression, integration — write one observable check.
- A check is observable if a third party could run it and get a yes/no answer without judgment. "It works" is not a check. "Web UI displays the formatted answer string after submit, not the generic SUBMITTED_SUMMARY fallback" is a check.
- Each criterion has a Status field: `open` / `met` / `failed`.
- Each criterion is written in plain language so the user can verify it without parsing agent jargon.
- **Alignment gate:** confirm the criteria with the user before starting execution. Post the journal path; ask them to read Section 2 and either approve or edit. The criteria are the contract; agree on them before billing time against them.

### 3. Task decomposition — from `karpathy-guidelines`

- Read `~/.pi/agent/skills/karpathy-guidelines/SKILL.md` before writing this section.
- Each task is the smallest sensible unit verifiable on its own.
- No single task should require more than 3–5 tool calls. If it does, decompose further.
- Mark dependencies — what blocks what.
- The decomposition is the workflow. Sketch it before any execution.

### 4. Initial hypothesis — debugging tasks only, from `debugging-protocol`

- Read `~/.pi/agent/skills/debugging-protocol/SKILL.md` before writing this section.
- State current best understanding of the problem in one sentence.
- List evidence *for* the hypothesis.
- List evidence *against* the hypothesis. Required, even if empty — the act of looking matters.
- State a falsifiable prediction: "if I observe X, the hypothesis is wrong".

## Per-attempt entries (during execution)

```
### Attempt N — <HH:MM>
- Sub-task: <which decomposition item / hypothesis>
- Action: <tool call sketch — file:line, or command>
- Expected: <what should happen if hypothesis right>
- Observed: <what actually happened — verbatim, including error text>
- Verdict: PASS | FAIL | INCONCLUSIVE
- Reason: <one sentence — must say *why*, not just what>
- Hypothesis update: <how this changes belief, or "no change">
```

Hard rules:

1. **The Verdict and Reason for Attempt N must be filled before Attempt N+1 is started.** No rolling-over.
2. **One attempt = one hypothesis being tested.** Three edits chasing the same hypothesis is one Attempt with three actions, not three Attempts.
3. **Reason cannot be empty even for PASS.** What specifically confirmed the hypothesis matters for the Lessons section later.
4. **"Observed" is verbatim.** Paste error output, tool output, screenshot description — do not summarise. Summarising hides the next clue.

## Failure-driven re-alignment

Hard triggers — when one of these fires, halt and execute the recovery:

| Trigger | Recovery |
|---|---|
| 3 FAIL/INCONCLUSIVE Attempts on same hypothesis | Stop editing. Re-read `debugging-protocol`. Spawn an `advisor` subagent with the full journal as brief. |
| 2 user contradictions in this task | Stop work. Re-quote the user verbatim. Restate success criteria. **Ask the user to confirm alignment** before any further edit. |
| Adding any fallback / cache / timeout / retry | Log it as a workaround in the Attempt. Add a follow-up sub-task that traces the real cause. The workaround is a debt, not a fix. |
| A criterion requires judgment to evaluate | The criterion is wrong. Rewrite it as a yes/no observable, and re-confirm with the user. |
| You realise you cannot state your current hypothesis in one sentence | Stop. Re-read the Attempts log. Restate before any further action. |

The recoveries are not optional. The whole point of the journal is that these conditions are *checkable* — the file makes them visible.

## End of task (before declaring done)

1. **Verify every success criterion individually.** Mark each `met` or `failed` against actual observed state. Any criterion `failed` or `open` means the task is not done. Show the user the criteria table before declaring done; they may dispute a `met`.
2. **Fill Lessons.** What worked, what didn't, what would I do differently. Be specific — "tests passed first try" is useless; "the JSON.stringify undefined-elision rule applied here, would have saved 3 hours if checked at the boundary" is a Lesson.
3. **Look for pattern-worthy material.** Any failure that recurred across this and past journals? Draft a wiki pattern under `~/.pi/llm-wiki/patterns/`.
4. **Archive.** Move the journal: `mv ~/.pi/runs/<slug>/journal.md ~/.pi/llm-wiki/projects/<proj>/runs/<date>-<slug>.md`. Update `~/.pi/runs/ACTIVE.md` to `no active journal`.
5. **Update project page.** Add a one-line link from `~/.pi/llm-wiki/projects/<proj>/overview.md`.

## Granularity guidance

The journal must be useful at re-read time. Two failure modes to avoid:

- **Too noisy.** Logging every keystroke. Rule: one entry per *hypothesis*, not per edit.
- **Too sparse.** Skipping updates under iteration pressure. Rule: if you cannot state your current hypothesis in one sentence, you have skipped too many updates — stop and catch up.

If you find yourself updating the journal less and less as the session goes on, you are in the framework-decay mode the journal exists to prevent. Stop, re-read the last 3 Attempts, restate the hypothesis, and resume.

## Cross-references

- `~/.pi/agent/skills/verification-protocol/SKILL.md` — source for the Success criteria section
- `~/.pi/agent/skills/debugging-protocol/SKILL.md` — source for the Hypothesis / Attempt loop
- `~/.pi/agent/skills/karpathy-guidelines/SKILL.md` — source for the Task decomposition rules
- `~/.pi/agent/skills/orchestrator-guidance/SKILL.md` — overall U/P/E/V framing; the journal is the durable substrate it runs on
- `~/.pi/llm-wiki/patterns/symptom-chasing-antipattern.md` — the failure pattern the journal exists to prevent
- `~/.pi/llm-wiki/patterns/framework-decay-under-iteration.md` — why an in-file journal beats an in-context skill paragraph
- Template to copy on task start: `~/.pi/agent/skills/run-journal/JOURNAL-TEMPLATE.md`
