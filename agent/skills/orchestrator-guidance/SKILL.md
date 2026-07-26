---
name: orchestrator-guidance
description: >
  Task orchestration framework. Use when asked to build, fix, implement, create,
  change, add, refactor, design, or architect anything non-trivial. Covers how to
  understand requirements, plan work, execute via subagents, and verify results.
  SKIP FOR: trivial lookups, one-liners, pure chat.
---

# Orchestrator Guidance

A systematic approach to completing tasks. These are principles and mental models,
not instructions. Apply them with judgment appropriate to the task — whether
coding, research, debugging, configuration, or architecture.

## The core insight

Most task failures are **understanding failures**, not execution failures.
A perfectly executed wrong plan is still wrong. A verified implementation
of a misdiagnosed bug still doesn't fix the bug.

This framework exists to prevent that: ensure the right thing is understood
before it's planned, and the right thing is built before it's declared done.

## Companion skills — read based on task type

This orchestrator framework tells you HOW to approach tasks. These companion
skills provide the detailed protocols. **Read them when the task matches the
trigger — before you start work, not after you get stuck.**

| Task type | Also read | Why |
|-----------|-----------|-----|
| Coding (build, implement, refactor, add feature) | `karpathy-guidelines` | Simplicity, surgical edits, goal-driven execution |
| Bug fix, debug, error, crash | `debugging-protocol` | Feedback loop construction, 7-phase discipline, anti-pattern recognition |
| Verify, test, validate, review | `verification-protocol` | Six dimensions, reviewer independence, metric design |
| Unclear requirements, multiple approaches | `grill-me-requirements` | Structured questioning, expected behavior |
| Unfamiliar project or codebase | `shared-language` | Domain glossary, CONTEXT.md |

## Dispositions, not procedures

These are not rules. They are dispositions — ways of thinking that produce
better outcomes. A procedure can be followed mindlessly. A disposition must
be exercised.

The goal is not compliance. It's cultivation of the move:

> "Before I change anything, let me understand what's actually happening."

That move can't be forced. It CAN be recognized when absent, and it CAN be
practiced. This document exists to make it recognizable and practiceable.

## Recognize these moments — they're observation points, not failures

These are the ReAct "Observe" step surfacing in your own behavior. When
you notice one, it's not that you messed up — it's that your last action
produced unexpected information, and the right move is to feed it back:

- **You're about to make a third edit to the same function** without the failure
  changing. The first two edits were observations — they told you your hypothesis
  is wrong. Stop acting and start understanding.
- **You're adding a fallback, timeout, or retry** because you don't understand
  why something hangs or fails. You're compensating for missing information.
  Trace instead.
- **You can't state in one sentence** why your last change should have worked.
  That means you acted without a prediction. You can't observe what you didn't
  predict.
- **The user contradicts your understanding** and you treat it as opinion rather
  than evidence. That's the most valuable observation you'll get — don't discard it.

See also: `patterns/symptom-chasing-antipattern.md` — a worked example from a
prior session where an agent ignored all four of these cues for two hours.

## User model

The orchestrator maintains a persistent model of the user at `~/.pi/user/`.
This is not generic behavioral patterns — it's knowledge about THIS specific
user: their preferences, personality, habits, and past decisions.

### Loading at session start

Before any work begins, read:
1. `~/.pi/user/PROFILE.md` — user-written preferences (always loaded fully)
2. `~/.pi/user/memory/MEMORY.md` — agent-written index (first 200 lines)
3. `~/.pi/user/memory/sessions/` — last 10-15 session summaries (lightweight cross-session awareness)

The profile tells you who you're working with. The memory index tells you
what's been learned across past sessions.

### Using during Understanding

When interpreting a request, check the user model:
- Has the user expressed a preference about this kind of task before?
- Has a similar task been done before — what approach was used?
- Are there standing instructions that apply?
- What's the user's communication style — should you ask questions or
  make decisions?

### Writing to memory — the three-gate filter

Not everything observed in a session belongs in memory. Every candidate must
pass three gates. Fail any one → don't store.

**Gate 1 — Persistence:** Will this still be true next month?
- PASS: "Prefers functional components over class components" (stable preference)
- FAIL: "Working on the login page" (that's a task, not a preference)
- Test: if you read this 30 days from now, would it still help?

**Gate 2 — Actionability:** Would knowing this change what the agent does?
- PASS: "Run type checks before considering a task done" (changes verification behavior)
- FAIL: "Uses VS Code" (the agent doesn't pick the editor)
- Test: can you name a concrete decision this memory would influence?

**Gate 3 — Non-obviousness:** Would the agent figure this out anyway?
- PASS: "Prefers TypeScript strict mode with noImplicitAny: false" (specific, non-obvious)
- FAIL: "Likes clean code" (everyone likes clean code; skills already say this)
- Test: if you deleted this memory, would the agent behave differently?

### Confidence tiers

When a candidate passes all three gates, assign a confidence tier:

| Tier | Trigger | Action |
|------|---------|--------|
| **EXPLICIT** | User says "remember X" or uses `/remember` | Store immediately, high confidence |
| **CORRECTION** | User corrects same thing ≥2 times | Store with "correction-driven" tag, medium-high confidence |
| **IMPLIED** | Pattern observed ≥3 times without explicit statement | Propose to user before storing, medium confidence |
| **CANDIDATE** | Observed once, seems significant | Note in candidates, promote only if confirmed in a second session |

Lower confidence = more willingness to re-ask the user rather than relying on the memory.

### Active usage during sessions

The user model isn't just loaded at start — it should be actively referenced
during the session:

- **Before asking a question:** check if the answer is already in memory
- **Before making a decision:** check if the user has a standing preference
- **When about to repeat a known mistake:** check `corrections.md`
- **When starting work on a known project:** check per-project memory
- **When user seems frustrated:** check if this is a known correction pattern

### Memory maintenance

Memories need lifecycle management, not just accumulation:

| Action | Trigger | What happens |
|--------|---------|-------------|
| **Consolidate** | 3+ memories about the same topic | Merge into one entry, remove duplicates |
| **Supersede** | New memory contradicts old | New replaces old; old marked as `[superseded]` with date |
| **Decay** | Memory not accessed in 30 days | Confidence downgraded one tier. After 60 days: flag for review |
| **Prune** | MEMORY.md exceeds 200 lines | Remove lowest-confidence, oldest entries first |
| **Promote** | Candidate confirmed in 2nd session | Move from candidates to active memory |

Maintenance happens during session startup (quick scan) and post-session
(via wiki-maintenance skill). The goal is to keep the working set of
memories lean and high-signal.

### Memory commands

The orchestrator should support these user commands:
- `/remember <fact>` — explicitly store something in memory
- `/memory` — show what's currently remembered
- `/forget <topic>` — remove a memory entry

## The U→P→E→V cycle

Four phases form the backbone of systematic work. The depth of each phase
scales with task complexity, but every phase should be considered.

### Understand

Know what you're actually solving — not just what was asked, but what's needed.

- **Trace the current path before diagnosing it.** If something isn't working,
  map every step from trigger to outcome. Expected vs actual at each step.
  The fix goes at the first step with a gap — not the last symptom you noticed.
  (The `debugging-protocol` has a concrete trace format with a worked example.)
- Probe beyond the surface. A user reports a symptom; the real problem may be
  elsewhere. A feature request may mask an unmet need.
- Gather relevant context. What parts of the system are involved? What don't
  you know yet? What assumptions are you making?
- Surface assumptions and gaps explicitly. An unstated assumption is a future bug.
- Design success criteria now, before any plan exists. What would prove the
  task is complete and correct? The task is only finished when every step in
  the workflow produces the expected output.

### Plan

Translate understanding into an actionable approach.

- The plan bridges "here's what's wrong" to "here's what we'll change and why."
- Every success criterion designed during understanding should be addressable.
- Surface tradeoffs: there are usually multiple approaches. Name them and the
  reasoning behind the choice.

### Execute

Execute is a cycle, not a batch. Borrowing from the ReAct architecture
(Think → Act → Observe), each action should be followed by observation:

- **Act:** make the change.
- **Observe:** what happened? Does the output match what you predicted?
- **Adapt:** if it matches, continue. If it doesn't, that's not failure —
  that's new information. Loop back to Understand with it.

Acting produces information, not just results. Even a "wrong" change tells
you something about the system. Feed that back before the next action.

### Verify

Prove the task is actually done. Not "looks right" — falsifiably done.

- Check against pre-designed criteria, not against the implementation.
- Check from multiple angles. A single test passing proves little.
- When verification fails, diagnose which phase failed and loop back there.

## Subagent strategy

Subagents are not a convenience — they are a core mechanism for systematic work.
Used well, they improve both quality (by matching model capability to task phase)
and efficiency (by isolating context and limiting token waste).

### Why subagents

| Benefit | How it works |
|---------|-------------|
| **Context isolation** | Each subagent gets fresh context. It doesn't carry the main agent's accumulated conversation bloat. |
| **Model matching** | Different phases need different cognitive horsepower. Match model to phase, not one model for everything. |
| **Parallel exploration** | Multiple scouts can explore codebase, web, and documentation simultaneously. |
| **Cognitive offload** | The orchestrator makes decisions. Subagents do the detailed work. Neither gets overwhelmed. |

### Model tiering

Not all phases need the same model quality. Match the model to the cognitive
demand of the phase:

| Phase | Cognitive demand | Model strategy |
|-------|-----------------|----------------|
| **Understand** | High — synthesis, gap detection, requirement validation | Best available model |
| **Plan** | High — architecture decisions, tradeoff analysis | Best available model |
| **Review / Verify** | High — catching subtle errors, security analysis | Best available model |
| **Execute** | Moderate — translating clear plan into code | Fast/cheap model |
| **Scout (gathering)** | Variable — codebase mapping is mechanical; research synthesis needs quality | Fast for exploration, best for synthesis |

**Principle:** Thinking is expensive; doing is cheap. Concentrate expensive
model capacity on phases where wrong decisions cascade — understanding,
planning, and verification. Use fast models for execution against a clear plan.

### Communication discipline

Subagents should communicate with the orchestrator using the simplest possible
terms that preserve the essential meaning. This is not just about saving tokens —
it forces true understanding. You can only simplify what you truly grasp.

**What subagents should produce:**
- Key findings, not full transcripts
- Decisions with rationale in one sentence, not paragraphs
- Evidence cited with file:line or URL — not copied verbatim
- "Here's what matters and why" — not "here's everything I found"

**What the orchestrator provides to subagents:**
- Self-contained task with all needed context (subagents don't inherit chat history)
- Clear scope: what to investigate, what NOT to investigate
- Expected output format: what the orchestrator needs to make the next decision

### Advisor pattern

When you are stuck — same task failing, can't articulate why, direction unclear —
spawn an advisor subagent. The advisor is a better model with fresh context.

**Brief the advisor with your story:**

1. The user's original request — **verbatim.** No paraphrase, no interpretation.
2. Your current understanding of the problem and what you've tried.
3. What has been failing and the evidence for each failure.
4. Your hypothesis about why it's failing (if you have one).

The advisor sees your reasoning because their job is to diagnose where it went wrong.

**When to spawn:**
- You notice any of the "recognize these moments" cues from above.
- You can't state in one sentence why your last fix should have worked.
- You're about to add a timeout/fallback because you don't understand the cause.
- The user says "step back" or "trace the workflow" — spawn an advisor, don't just
  promise to think harder.

**When NOT to spawn:**
- First failure on a task (try diagnosing yourself first).
- Trivial mistakes that you can identify and fix immediately.
- The problem is clearly in execution (wrong implementation of right plan).

### Reviewer pattern (independence-first)

When you believe you are done — spawn a reviewer subagent. **Do not tell them
what you did.** If you tell a reviewer your implementation story, they will
verify your story instead of verifying the user's need.

**Brief the reviewer ONLY with:**

1. The user's verbatim request — exactly as stated, no paraphrase.
2. The user's corrections and refusals during the session — verbatim.
3. Acceptance criteria designed during Understanding — observable, falsifiable.
4. Artifacts to inspect — URLs, deployed dist, WS endpoints, DOM state, etc.

**Deliberately withhold:** how the implementation works, which files were changed,
what you believed the bug was, which approaches you tried.

**Self-check:** if the reviewer had never seen your messages, could they still
verify the work? If yes, the brief is clean. If no, you leaked your story.

**The reviewer's output:**
- Each criterion: pass / fail / partial — with evidence (screenshot, log, file:line).
- Gaps: criteria that fail to cover what the user actually asked for.
- Over-delivery: anything the user did NOT request that was added anyway.
- Sniff-test: anything that feels off even if it passes formal criteria.

This is the operational form of the core insight from `verification-protocol`:
"Check against pre-designed criteria, not against the implementation."

### When NOT to spawn subagents

Subagents have overhead. Don't spawn them when:
- The task fits in a single read or edit
- The codebase is small enough to read directly
- The answer is obvious from context
- Spawning would add more coordination cost than the work itself

**Principle:** Subagents solve the problem of too much context, not the
problem of not enough context. If you can do the work directly in under
3-4 tool calls, do it directly.

## Principles for active questioning

Questions prevent assumptions from becoming bugs.

**When to question:**
- Requirements are ambiguous (multiple interpretations possible)
- Multiple valid approaches exist with meaningful tradeoffs
- Expected behavior in edge cases isn't clear
- Success criteria are vague
- You're about to make an assumption that could be wrong

**How to question:**
- One decision at a time. Bundled questions get confused answers.
- Make tradeoffs concrete: "Option A gives X but costs Y. Option B gives Z
  but costs W. Which matters more?"
- Every question should narrow uncertainty. If the answer wouldn't change
  what you do, don't ask.

## Principles for uncertainty

Confidence should be explicit and calibrated:

- Distinguish facts from inferences. "The trace shows X at file:line. This
  SUGGESTS Y, but Z hasn't been ruled out."
- Name your assumptions. Every assumption is a failure point.
- Update when wrong. Being wrong is data — use it to refine understanding.

## When this framework applies

This framework is a tool, not a cage. Apply it when direction matters —
when getting it wrong costs more than taking time to get it right.

The judgment of which tasks warrant which depth improves with use.

## Related frameworks

- `verification-protocol` — principles for designing and executing
  verification metrics across different task types
- `grill-me-requirements` — structured approach to interactive requirement
  clarification
- `karpathy-guidelines` — principles for code quality and simplicity

## Architecture reference

See the [agent orchestration architecture](../llm-wiki/built/agent-orchestration-architecture.md)
for the full system design this framework operates within.
