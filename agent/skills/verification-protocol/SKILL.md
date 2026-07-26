---
name: verification-protocol
description: >
  Verification and testing framework. Use when asked to test, verify, validate,
  check, or review code — or when determining if a task is actually done. Covers
  test design, correctness checking, security review, and regression testing.
---

# Verification Protocol

A framework for proving work is done — not through ritual, but through
falsifiable checks designed from requirements, not from implementation.

## The core problem with verification

The most common verification failure: metrics that validate the implementation
rather than the requirement.

A test that checks "does the code do what I wrote?" will always pass —
because you wrote the test to match what you wrote. But a test that checks
"does the system behave as the user expects?" might fail, and that failure
is the one that matters.

This framework exists to prevent self-validating verification.

## Six dimensions of verification quality

Every task can be evaluated across these dimensions. Not all dimensions
carry equal weight for every task — their importance varies by context.

### Correctness

Does the system behave as it should?

For software: does the output match the expected output for all relevant
inputs — including edge cases, error conditions, and boundary values?

For research: are claims falsifiable and supported by evidence that a
skeptical reader could verify?

**Principle:** Correctness is measured against requirements, not against
the implementation. "The code does what I intended" is not correctness.
"The system behaves as the user needs" is.

### Completeness

Is anything missing that should be present?

For software: are all acceptance criteria addressed? Are error states
handled? Are empty, loading, and edge states covered? Are there
undocumented behaviors or silent failures?

For research: are there unexplored perspectives that would change the
conclusion? Are limitations and unknowns explicitly named?

**Principle:** Completeness is about what's NOT there. It's harder to
verify than correctness because you're checking for absence. The best
approach: define upfront what "complete" looks like, then verify
against that definition.

### Quality

Is the work well-constructed for its purpose?

For software: is it the simplest solution that works? Does it avoid
over-engineering (abstractions without present need, generality without
present use)? Is it readable and consistent with surrounding patterns?

For research: is the reasoning clear? Are claims properly qualified?
Is the structure logical?

**Principle:** Quality is contextual. A throwaway script has different
quality standards than a core library. Match the quality bar to the
artifact's expected lifetime and audience.

### Security

Could this work cause harm?

For software: are trust boundaries respected? Are external inputs
validated? Are secrets or sensitive data exposed? Could an adversary
exploit this change?

For research: are there dangerous recommendations? Are privacy or
ethical implications considered?

**Principle:** Security failures are asymmetric — one vulnerability
can outweigh all other qualities. Even "small" changes can introduce
them. The question is not "did I add anything insecure?" but "could
anything in this change be exploited?"

### Regression

Did anything that worked before stop working?

For software: do existing tests pass? Does related functionality
still behave correctly? Are APIs still compatible? Does the build
succeed?

For research: does the new work contradict established findings?
If so, is the contradiction resolved or acknowledged?

**Principle:** Regression is the easiest dimension to skip and the
most embarrassing to discover late. The cost of checking is low;
the cost of not checking can be catastrophic.

### Integration

Does this work fit with everything around it?

For software: are contracts with other components maintained? Does
data flow correctly end-to-end? Are dependencies compatible?

For research: does this connect to and extend existing knowledge?
Does it fit the project's context and constraints?

**Principle:** Nothing exists in isolation. A perfectly correct
component that breaks its neighbors is still a failure.

## Principles for metric design

### Design metrics before solutions

The time to define "done" is before you start building. Once an
implementation exists, the human tendency is to design verification
that validates what was built rather than what was needed.

Designing metrics early forces clarity about requirements. If you
can't define what "correct" looks like, you don't understand the
problem well enough to solve it.

### Make metrics falsifiable

A good metric can fail. "The system should be fast" can't fail —
what's "fast"? "Page load under 200ms at p95" can fail.

For correctness: "the button submits the form" is good. "The form
works" is vague. "Submitting with empty required fields shows
validation errors; submitting with valid data creates a record;
submitting while offline shows an error" — now you have falsifiable
checks.

### Vary the angle of verification

A single verification method can be fooled. Multiple independent
methods converging on "correct" builds real confidence:

- Automated tests + manual exploration + code review
- Unit tests + integration tests + E2E smoke test
- Happy path + error path + edge cases + boundary values

When different verification methods agree, confidence is high.
When they disagree, you've found something worth investigating.

### Weight dimensions by task type

Not all dimensions matter equally:

| Task type | Primary dimensions | Secondary |
|-----------|-------------------|-----------|
| Bug fix | Correctness (does bug still reproduce?), Regression | Completeness, Security |
| Feature | Correctness, Completeness | Quality, Integration |
| Refactor | Regression, Correctness (behavior unchanged) | Quality |
| Research | Correctness (evidence-backed), Completeness (perspectives) | Integration |
| Configuration | Correctness, Security | Regression |
| Security fix | Security, Regression | Correctness |

### Calibrate depth to risk

The verification depth should match the cost of being wrong:

- **High risk** (auth, payments, data loss, security): exhaustive
  verification across all six dimensions
- **Medium risk** (user-facing feature, API change): thorough
  verification of primary dimensions, spot-check secondary
- **Low risk** (typo, log message, comment): lightweight check —
  correctness + quick regression smoke test

## Principles for test-driven verification

When tests are the primary verification mechanism, how they're written
matters as much as whether they pass.

### Vertical slicing — the correct approach

Write ONE test, make it pass, then write the next. Never write all tests
before writing any implementation:

```
WRONG (horizontal slicing):
  Write test1, test2, test3, test4, test5
  Then implement all at once

CORRECT (vertical slicing):
  Write test1 → implement → passes
  Write test2 → implement → passes
  Write test3 → implement → passes
```

Horizontal slicing produces tests coupled to imagined behavior. When
you write tests in bulk before any code exists, you're testing the shape
of things (data structures, signatures) rather than actual behavior.
These tests become insensitive — they pass when behavior breaks, fail
when behavior is fine.

Vertical slicing means each test responds to what you learned from the
previous cycle. Because you just wrote the code, you know exactly what
behavior matters and how to verify it.

### Test behavior, not implementation

Tests should verify what the system does through public interfaces,
not how it does it internally. A good test survives a refactor — the
implementation changes but the test still passes because the behavior
hasn't changed.

**Good test:** "User can checkout with valid cart" — verifies behavior
**Bad test:** "CheckoutService calls PaymentProcessor.process()" — verifies implementation

If renaming an internal function breaks tests, those tests were testing
implementation, not behavior.

### One behavior per test

Each test should verify one aspect of behavior. When a test verifies
multiple unrelated things, a failure tells you something is wrong but
not what. One assertion per test is ideal; multiple assertions that
test the same behavior are acceptable.

### Regression tests at the correct seam

After fixing a bug, write a regression test at the seam where the bug
occurred — the interface where the wrong behavior was observable. The
test should exercise the real bug pattern as it occurs at the call site.

If no correct seam exists (the bug requires a chain of callers that a
unit test can't replicate), that itself is a finding. The architecture
is preventing the bug from being locked down. Note it.

## Patterns for diagnosing verification failures

When verification fails, the question is not "how do I fix this?"
but "which phase produced the wrong thing?"

| Failure pattern | Usually means | Trace back to |
|----------------|---------------|---------------|
| Correctness failures despite clean execution | Misunderstood the requirement | Understanding |
| Completeness failures (missing edge cases) | Didn't explore the problem space fully | Understanding |
| Quality failures (over-engineered, messy) | Rushed execution without review | Execution |
| Security failures | Security not considered during design | Understanding or Planning |
| Regression failures | Didn't map dependencies and impact | Understanding |
| Integration failures | Assumptions about other components were wrong | Understanding |

**The pattern:** most failures trace to Understanding, not Execution.
When something is wrong, first ask: "Did we understand this correctly?"

## Minimum verification

Not every task warrants full verification. For changes where the cost
of being wrong is low, a lightweight check suffices:

1. Does the change produce the expected result? (one check)
2. Does anything obviously break? (smoke test)
3. Could anything be exposed? (quick security thought)

If any of these raises doubt, escalate to systematic verification.

## Path coverage — not a number, a thinking model

"100% branch coverage" is a trap. It rewards writing tests whose only
purpose is hitting branches, not verifying behavior. Those tests survive
refactors but catch no bugs.

Instead: **for each step in the workflow, list the paths through it:**

| Path | What it means | Test it? |
|------|--------------|----------|
| Happy | Normal input → expected output | Always |
| Error | Invalid input → handled gracefully | If the error can occur in practice |
| Boundary | Edge input (empty, max length, zero, negative) | If the boundary matters to the user |
| Empty | No input / null / undefined | Always (crashes here are embarrassing) |

Test the paths that can actually occur. Document the ones that can't.
The goal is knowing which paths are untested and why — not hitting a number.

## Before declaring done — completeness check

Every item below can be skipped with a reason. But you can't skip all of
them without knowing you skipped them:

- [ ] Re-traced from step 1 — every gap now "no"
- [ ] Original failure scenario produces expected output
- [ ] At least one edge case tested (empty input, error input, boundary)
- [ ] Regression smoke test passed on related functionality
- [ ] Wrong assumption documented (wiki, comment, or memory)
- [ ] All debug instrumentation removed

## Related frameworks

- `orchestrator-guidance` — the orchestrator framework that uses this
  verification protocol during the Understand and Verify phases
- `karpathy-guidelines` — code quality principles that inform the
  Quality dimension

## Briefing a reviewer vs briefing an advisor

The orchestrator's subagent strategy uses two roles with opposite briefing
requirements:

### Reviewer — brief with the CONTRACT, never the story

The reviewer's job: check whether the user got what they asked for.
That job dies the moment you tell the reviewer what you did.

**Send the reviewer:**
- The user's verbatim request — exactly as stated.
- The user's corrections and refusals during the session — verbatim.
  ("No, not timeout — that's the worst way." — this is a hard constraint.)
- Acceptance criteria — observable and falsifiable.
- Artifacts to inspect — URLs, deployed dist, WS endpoints, DOM state.

**Do NOT send the reviewer:**
- Which files were changed.
- What you believed the bug was.
- How you implemented the fix.
- Which approaches you tried and discarded.

The reviewer seeing your implementation will verify your story, not the
user's need. If the reviewer had never seen your messages, could they still
verify the work? If yes, the brief is clean.

### Advisor — brief with your STORY

The advisor's job: diagnose why you're stuck. They NEED your reasoning
because they're debugging your debugging.

**Send the advisor:**
- The user's verbatim request.
- Your current understanding of the problem.
- What you've tried and the evidence for each failure.
- Your hypothesis (if you have one).

The advisor sees everything the main agent sees. Their fresh perspective
catches assumptions the main agent has stopped noticing.

### The principle in one sentence

> Reviewers verify the outcome against the requirement.
> Advisors diagnose the process against the evidence.
> Tell the reviewer what was needed. Tell the advisor what was tried.
