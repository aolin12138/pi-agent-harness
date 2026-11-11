---
name: karpathy-guidelines
description: >
  Engineering taste for writing and reviewing code changes: make the smallest change
  that solves the problem, surface assumptions, define verifiable success criteria
  before coding, reuse existing patterns over new abstractions, and avoid
  over-engineering. Use before writing or reviewing any code change, and as the
  quality bar for planner / executor / reviewer subagents. Referenced by AGENTS.md §6
  and by every subagent definition.
---

# Karpathy guidelines

Simple, surgical, goal-driven engineering. The job is to solve the actual problem with the
least new complexity — not to demonstrate architecture. Most regressions come from changing
more than the problem required.

## The bar

1. **Understand before you change.** Read the surrounding code and name the real cause before
   editing. A fix aimed at a symptom you haven't located is a guess. If you can't state the
   cause in one sentence, you're not ready to edit.
2. **Smallest change that works.** Make the surgical edit the bug needs — do not rework
   architecture for a one-line fix. Small diffs are easier to verify, review, and revert.
3. **Surface assumptions explicitly.** State what you're assuming about inputs, invariants, and
   call sites. Name the assumption instead of silently relying on it; an unnamed assumption is
   a future bug.
4. **Define verifiable success criteria first.** Before coding, write the observable yes/no
   check that will show the change worked. Code toward that check, not toward "it looks right".
5. **Reuse existing patterns over new abstractions.** Match the conventions already in the file
   / module. Introduce a new abstraction only when the duplication is real and repeated
   (rule of three), never on speculation.
6. **No over-engineering (YAGNI).** Don't add config, layers, hooks, generality, fallbacks,
   caches, timeouts, or retries that the task did not ask for. Every one is surface area that
   can fail. If you reach for one, write down *why* and trace the cause first.
7. **Make it work, then make it right, then (only if needed) make it fast.** Correctness before
   cleanliness before performance. Don't optimize what you haven't measured.
8. **Delete before you add.** Removing code is often the better fix. Less code, fewer bugs.
9. **Leave the diff explainable.** You should be able to say, line by line, why each change is
   there. If part of a diff is "just in case", cut it.

## When reviewing (planner / executor / reviewer subagents)

Judge a change against: does it solve the stated goal, is it the smallest change that does so,
are its assumptions named, is there an observable check that it works, does it reuse existing
patterns, and does it avoid speculative generality. Flag any edit that changes more than the
goal requires, adds an unrequested fallback/cache/retry, or introduces an abstraction with a
single caller.

## Smell test before declaring done

- Can I state the root cause in one sentence?
- Is this the smallest change that fixes it?
- Did I name my assumptions, and is there a yes/no check that it works?
- Did I reuse the existing pattern instead of inventing one?
- Is every line in the diff something I can justify?

If any answer is "no", stop and narrow the change.
