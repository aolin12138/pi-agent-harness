---
title: "Run Journal — diagnostic substrate for non-trivial tasks"
type: built
updated: 2026-06-09
sources:
  - "~/.pi/agent/skills/run-journal/SKILL.md"
  - "~/.pi/agent/skills/run-journal/JOURNAL-TEMPLATE.md"
  - "~/.pi/agent/AGENTS.md"
  - "session 2026-06-09 design discussion"
tags: [agent-infrastructure, skills, debugging, orchestration, user-facing]
---

# Run Journal

A live markdown file maintained during non-trivial agent work. It externalises the agent's working memory — verbatim user request, agreed success criteria, smallest task decomposition, current hypothesis, and a per-attempt log — into a file that both the **agent and the user** can read and edit during the run.

## Why it exists

It is a direct response to two documented failure patterns:

- `patterns/symptom-chasing-antipattern.md` — agent makes many edits without checking expected-vs-actual, drops the engineering framework, fails to step back.
- `patterns/framework-decay-under-iteration.md` — frameworks loaded at session start lose behavioural pressure over a long debugging tail; the agent "forgets which phase it's in" and reverts to undisciplined editing.

The journal is the durable substrate for U→P→E→V. The framework lives in the *file* the agent must edit at each step, not in the chat it skims once at start.

## Design principles

1. **For both agent and user.** The user reads it to verify alignment and watch progress. The user may also edit it (correcting the verbatim request, sharpening criteria, leaving notes). Agent re-reads before every tool call.
2. **Status visible at top.** A status header table — phase, criteria met, last attempt verdict, user action requested — plus a one-paragraph plain-language summary. Both readable in 10 seconds.
3. **Construction via engineering skills, not freeform.** Each section has a sourcing skill that must be read before the section is filled:
   - Section 2 (success criteria) ← `verification-protocol`
   - Section 3 (task decomposition) ← `karpathy-guidelines`
   - Section 4 (hypothesis) ← `debugging-protocol`
4. **Hard alignment gates.** After Section 1 (verbatim request) and after Section 2 (criteria), the agent posts the journal path and asks the user to confirm. No execution starts until the contract is agreed.
5. **One attempt = one hypothesis.** Not one tool call. Three edits chasing the same belief is one Attempt with three actions, which means the "3 FAIL Attempts → halt + advisor" trigger fires fast.
6. **Failure-driven recovery is automatic.** Hard triggers in the skill enumerate when to halt, re-quote the user, spawn an advisor, or log a workaround as debt.

## Filesystem layout

| Path | Purpose |
|---|---|
| `~/.pi/runs/<date>-<slug>/journal.md` | Active journal during the run |
| `~/.pi/runs/ACTIVE.md` | Always-current pointer + status snapshot the user can `cat` any time |
| `<repo>/.wiki/runs/<date>-<slug>.md` | Archive on task end |
| `~/.pi/llm-wiki/patterns/<new>.md` | If Lessons reveal a recurring failure mode, promoted to a wiki pattern |
| `~/.pi/agent/skills/run-journal/SKILL.md` | The skill that teaches when and how to use the journal |
| `~/.pi/agent/skills/run-journal/JOURNAL-TEMPLATE.md` | Copied at task start |

## When to start one

Triggers (from the skill):

- Task expected to take more than ~5 tool calls
- Task has a debugging component
- User has reformulated the request 2+ times
- A previous journal exists under `projects/<proj>/runs/` for the same problem

Skipped for trivial lookups, one-line edits, or pure chat.

## Per-attempt entry shape

```
### Attempt N — HH:MM
- Sub-task: <decomposition item or "test hypothesis">
- Action: <tool call sketch, file:line>
- Expected: <if hypothesis right>
- Observed: <verbatim — paste error text, tool output>
- Verdict: PASS | FAIL | INCONCLUSIVE
- Reason: <one sentence — *why*>
- Hypothesis update: <how belief changes>
```

Hard rule: Verdict + Reason for Attempt N must be filled before Attempt N+1 starts.

## Failure-driven recovery

| Trigger | Recovery |
|---|---|
| 3 FAIL/INCONCLUSIVE on same hypothesis | Stop. Read `debugging-protocol`. Spawn `advisor` with journal as brief. |
| 2 user contradictions in task | Stop. Re-quote user verbatim. Restate criteria. Confirm alignment before next edit. |
| Adding fallback / cache / timeout / retry | Log as workaround in Attempt. Add follow-up to trace real cause. Workaround = debt. |
| Cannot state hypothesis in one sentence | Stop. Re-read last 3 Attempts. Restate. |
| Criterion needs judgment to evaluate | Criterion is wrong. Rewrite as observable. Re-confirm with user. |

## Integration with the agent ecosystem

- **AGENTS.md §3** — requires starting a journal for any non-trivial task.
- **Task list** — task list tracks *what to do*; journal tracks *what I believe and why I think work is done*. Both run in parallel; they answer different questions.
- **Advisor subagent** — when the journal triggers an advisor, the journal *is* the brief. No re-summarising of state.
- **Wiki** — closed journals archive to `projects/<proj>/runs/`; recurring failure patterns get promoted to `patterns/`. The journal feeds the wiki, the wiki feeds the next journal.

## Open questions

- **Concurrency.** The skill currently says "agent never silently overwrites a user edit — stop and ask". Conservative but possibly chatty. A softer ownership-by-section model (agent owns status-header + Attempt N+1; user owns §1, §2, §6) may be more practical once we observe real usage.
- **Enforcement.** The skill is read-on-trigger, not harness-enforced. If the file isn't updated under pressure, decay returns. A pi extension that watches tool calls and reminds when the journal hasn't been updated in N calls is the obvious next step — deferred until we see whether the format alone changes behaviour.

## Cross-references

- `patterns/symptom-chasing-antipattern.md` — what the journal exists to prevent
- `patterns/framework-decay-under-iteration.md` — why the journal must live as a file, not as a paragraph in context
- `built/skills.md` — skill registry
- `built/subagent-system.md` — how `advisor` works (briefed with the journal when triggered)
- `built/user-model.md` — PROFILE / memory; journal is the per-task layer that feeds session summaries
