---
name: grill-me-requirements
description: >
  Requirement clarification through interactive questions. Use when requirements
  are unclear, when the user asks "what should I build" or "how should I design
  this", when multiple approaches exist, or when you need to understand expected
  behavior before fixing a bug.
---

# Grill-Me Requirements

A framework for clarifying what needs to be built and how we'll know it's
right — through structured interactive questioning that narrows uncertainty
before any plan or code is committed.

## The core insight

Requirements live in the user's head, not in their words. What a user says
and what they need are often different. A bug report describes a symptom,
not a cause. A feature request describes a surface desire, not the
underlying need. The fastest way to build the wrong thing is to accept
the user's words literally without probing.

This framework exists to uncover the real requirements — not through
assumption, but through structured clarification.

## What to clarify

### For any task: verification criteria

Before discussing implementation, establish what "done" means. This is
the single highest-leverage question because it reveals whether the user
has thought through what success looks like.

Questions to explore:
- How will you know this is working correctly?
- What would make you reject the result?
- What edge cases or failure modes matter most?

When the user can't answer these, the requirements aren't ready for
implementation. The discussion itself clarifies them.

### For debugging: expected behavior

A bug exists because the system behaves differently from expectations.
Before investigating code, understand the expectation:

- What should happen in this scenario?
- What actually happens? (The gap is the bug)
- Under what conditions does the discrepancy occur?
- Has this ever worked correctly before? If so, what changed?

This prevents the most common debugging failure: searching code for
"patterns that look wrong" instead of tracing from expected behavior
to actual behavior and finding the divergence point.

### For features: the underlying need

A feature request describes a solution. The real question is: what
problem does this solve?

- What can't you do today that you need to do?
- What would change in your workflow if this existed?
- What's the simplest thing that would solve this problem?

This surfaces whether the requested feature is the right solution
or whether a simpler approach would serve the need.

### For decisions with tradeoffs

When multiple valid approaches exist, the choice depends on values
the user holds but may not have articulated:

- Is speed or correctness more important here?
- Is this a prototype or production code?
- Will this need to change frequently or is it stable?
- Who else will work with this? What do they need?

Present options with their concrete tradeoffs — not abstract pros/cons,
but "if we choose A, you get X but lose Y. If we choose B, you get Z
but pay W." Let the user weight the tradeoffs.

## Principles for effective questioning

### One decision per question

Bundled questions produce bundled answers. "Should we use React or Vue,
and should we deploy on AWS or Azure, and should we use TypeScript?"
gets a confused response. One decision at a time builds clarity.

### Make options concrete

"How should we handle errors?" invites vague answers. Instead:
- "Option A: fail loudly with user-visible error (easier to debug, worse UX)"
- "Option B: fail silently with fallback (better UX, harder to debug)"
- "Option C: log error + notify user with a toast (balanced)"

### Stop when enough

Not every uncertainty needs resolution. The threshold: would the answer
change what you'd do? If not, proceed with a reasonable default and flag
the assumption.

### Capture decisions

After each clarification, confirm in one line: "Confirmed: we'll use
Option B — silent fallback with logging." This builds a decision trail
that prevents later confusion.

## Question prioritization

Not all gaps are equally urgent. Prioritize by impact:

1. **Success criteria** — how do we know it's done? (Without this, all
   other answers are moot.)
2. **Expected behavior / scope** — what should happen? What's in and
   what's out?
3. **Constraints and tradeoffs** — what limits exist? What values
   determine the approach?
4. **Implementation preferences** — specific stack, style, or pattern
   choices (lowest impact, can often be defaulted)

## Decision capture before proceeding

Before transitioning from requirements to planning, summarize what's
been established:

- What we're building and why
- What "done" looks like (verification criteria)
- Key constraints and assumptions
- Tradeoffs made and the reasoning
- What's still uncertain (and why it's safe to proceed anyway)

This summary serves as the contract between understanding and planning.
If the plan doesn't address these points, either the plan is wrong or
the understanding was incomplete.

## When to grill

This framework is a tool, not a gate. Apply it when:

- Requirements are ambiguous or incomplete
- The task is high-impact (wrong direction is costly)
- Multiple valid approaches exist with meaningful tradeoffs
- Debugging — expected behavior needs to be established
- The user's request feels like a solution, not a problem statement

Skip it when:

- Requirements are clear and uncontroversial
- The task is trivial (typo, one-line change)
- The user is explicitly giving a direct instruction

## Related frameworks

- `orchestrator-guidance` — the orchestrator uses this during the
  Understand phase to clarify requirements before planning
- `verification-protocol` — verification criteria explored here become
  the metrics verified there
