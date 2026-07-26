# <Task name>

## Status — at a glance

> Updated by the agent before every tool call that changes state. The user reads this row first.

| Field | Value |
|---|---|
| **Phase** | <Setting up / Awaiting user confirmation on §N / Executing §N task M / Halted: <reason> / Done> |
| **Criteria met** | <m> of <n> |
| **Last attempt** | <Attempt N — verdict — one-line reason> |
| **Last update** | <YYYY-MM-DD HH:MM> |
| **User action requested** | <none / confirm §1 verbatim / confirm §2 criteria / resolve contradiction / ...> |

**Plain-language summary (one paragraph):**
<one paragraph the user can read in 10 seconds to know where we are and what's next>

---

Started: <YYYY-MM-DD HH:MM>
Project: <project>
Journal path: <absolute path>

---

## 1. User request — verbatim

> <paste user's exact words here — no editing>

Agent paraphrase: <one-line restatement>

**Confirmation with user:** <pending / confirmed / corrected by user>

> User: if the verbatim quote above does not match what you asked for, edit it directly. The agent will re-read before its next tool call.

---

## 2. Success criteria

> Constructed using `~/.pi/agent/skills/verification-protocol/SKILL.md`.
> Each row is an observable yes/no check, written in plain language so you can verify without parsing agent jargon. Remove dimensions that do not apply.

| Dimension | Check (plain language) | Status |
|---|---|---|
| Correctness | <observable yes/no condition> | open |
| Completeness | <...> | open |
| Quality | <...> | open |
| Security | <...> | open |
| Regression | <...> | open |
| Integration | <...> | open |

**Confirmation with user:** <pending / confirmed / corrected by user>

> User: edit any check that doesn't capture what you actually want. Add or remove rows freely.

---

## 3. Task decomposition

> Constructed using `~/.pi/agent/skills/karpathy-guidelines/SKILL.md`.
> Smallest sensible units. No item should take more than 3-5 tool calls.

1. <task> — depends on: none
2. <task> — depends on: #1
3. <task> — depends on: #1
4. ...

---

## 4. Initial hypothesis

> Only for debugging tasks. Constructed using `~/.pi/agent/skills/debugging-protocol/SKILL.md`.

- **Belief (one sentence):** <...>
- **Evidence for:**
  - <bullet>
- **Evidence against (required; write "none yet" if so):**
  - <bullet>
- **Falsifiable prediction:** if I observe <X>, the hypothesis is wrong.

---

## 5. Attempts

> One Attempt = one hypothesis being tested, not one tool call. The Verdict and Reason for Attempt N must be filled before Attempt N+1 starts.

### Attempt 1 — <HH:MM>
- **Sub-task:** <#N from decomposition or "test hypothesis">
- **Action:** <tool call sketch, file:line>
- **Expected:** <what should happen if hypothesis right>
- **Observed:** <verbatim — paste error text, tool output, screenshot description>
- **Verdict:** <PASS | FAIL | INCONCLUSIVE>
- **Reason (plain language):** <one sentence — *why*, not just *what*>
- **Hypothesis update:** <how belief changes, or "no change">

### Attempt 2 — <HH:MM>
- ...

---

## 6. User notes

> Free space for the user. Add corrections, redirections, missing context, or just questions. The agent re-reads before its next tool call.

- <empty>

---

## 7. Lessons (filled at task end)

- <specific, transferable learnings — not "tests passed">
- <pattern-worthy items get promoted to ~/.pi/llm-wiki/patterns/>

---

## 8. Closeout

- **Success criteria met (per-criterion):**
  - Correctness: <met / failed>
  - ...
- **Pattern promotion candidate:** <none | path to draft pattern>
- **Archived to:** <wiki path>
- **Project page updated:** <yes / no>
