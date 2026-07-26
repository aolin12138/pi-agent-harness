---
title: "Agent Orchestration Architecture — U→P→E→V System"
type: concept
updated: 2026-06-02
status: draft
tags: [architecture, orchestration, workflows, agents, verification]
---

# Agent Orchestration Architecture

System-level design for a meta-cognitive agent architecture centered on
**Understanding → Planning → Execution → Verification** with explicit
gates, comprehensive verification metrics, and proactive human collaboration.

## §1 System overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR (Main Agent)                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐   │
│  │ Question │ │ Decision │ │Subagent  │ │ Iteration        │   │
│  │ Protocol │ │ Gateway  │ │Coordinator│ │ Controller       │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘   │
│                                                                 │
│  "Project manager" — does NOT implement, coordinates everything.
  When stuck, spawns advisor for diagnosis and redirection. │
└──────────────────────────┬──────────────────────────────────────┘
                           │ spawns / gates
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    WORKFLOW ENGINE                               │
│                                                                 │
│  ┌──────────────┐    ┌──────────┐    ┌──────────┐    ┌───────┐ │
│  │ UNDERSTAND   │───▶│  PLAN    │───▶│ EXECUTE  │───▶│VERIFY │ │
│  │              │    │          │    │          │    │       │ │
│  │ Gate:        │    │ Gate:    │    │ Gate:    │    │Gate:  │ │
│  │ context ✓    │    │ plan     │    │ impl     │    │all    │ │
│  │ reqs ✓       │    │ reviewed │    │ passes   │    │metrics│ │
│  │ metrics      │    │ approved │    │ review   │    │pass   │ │
│  │ designed ✓   │    │          │    │          │    │       │ │
│  └──────┬───────┘    └────┬─────┘    └────┬─────┘    └───┬───┘ │
│         │                 │               │              │      │
│         ▼                 ▼               ▼              ▼      │
│  ┌──────────┐      ┌──────────┐     ┌──────────┐   ┌────────┐  │
│  │ Scout(s) │      │ Planner  │     │ Executor │   │Reviewer│  │
│  │ (parallel│      │          │     │          │   │+ Verif.│  │
│  │  modes)  │      │          │     │          │   │ Agents │  │
│  └──────────┘      └──────────┘     └──────────┘   └────────┘  │
│                                                                 │
│  ◀───────── ITERATION LOOP (back to any phase) ─────────────▶  │
└─────────────────────────────────────────────────────────────────┘
```

### Core principle

The orchestrator (main agent) never implements. It:
1. **Questions** the user to clarify requirements, expected behavior, success criteria
2. **Delegates** each phase to specialized subagents
3. **Gates** progression — no phase advances until its gate conditions are met
4. **Iterates** — verification failures loop back to the appropriate phase
5. **Acknowledges uncertainty** — never assumes, always asks when unsure

## §2 Phase definitions

### Phase 1: UNDERSTANDING

**Goal:** Build sufficient context to make correct decisions.

**Gate conditions (all must be met before advancing to Plan):**
- [ ] Context gathered: codebase explored, relevant files identified, dependencies mapped
- [ ] Requirements clarified: not just user's words — actual needs, expected behavior, edge cases
- [ ] Success metrics designed: how will we know this is done? (see §5 Verification Protocol)
- [ ] Uncertainty surfaced: what don't we know? What assumptions are we making?
- [ ] User confirmed understanding (for ambiguous/high-impact tasks)

**Subagents:**
- **Codebase scout** — map structure, identify relevant modules, trace data flow
- **Web research scout** — multi-perspective research on topic/technology
- **Bug-reproduction scout** — replicate error state, trace root cause (for debugging)
- **Requirement-validation scout** — challenge assumptions, find missing edge cases

**What understanding looks like for different task types:**

| Task Type | Understanding Output |
|-----------|---------------------|
| Bug fix | Reproduced error, traced root cause, identified affected code path, understood expected vs actual behavior |
| Feature | User need clarified, existing architecture understood, integration points identified, tradeoffs surfaced |
| Research | Multiple perspectives gathered, key disagreements identified, evidence quality assessed, applicable mental models extracted |
| Refactor | Current architecture mapped, pain points identified, constraints understood, regression risk assessed |

### Phase 2: PLANNING

**Goal:** Produce a reviewed, approved implementation plan.

**Gate conditions:**
- [ ] Plan addresses all clarified requirements
- [ ] Plan accounts for known constraints and risks
- [ ] Plan reviewed by reviewer subagent
- [ ] User approved (for high-impact changes)

**Subagents:** planner → reviewer (review the plan itself)

### Phase 3: EXECUTION

**Goal:** Implement according to the approved plan.

**Gate conditions:**
- [ ] All planned changes implemented
- [ ] Code passes preliminary self-review
- [ ] No unplanned side effects

**Subagents:** executor

### Phase 4: VERIFICATION

**Goal:** Prove the implementation is correct, complete, and safe.

**Gate conditions (all must be met before task is "done"):**
- [ ] Correctness: tests pass, expected behavior confirmed, edge cases handled
- [ ] Quality: code is maintainable, no over-engineering, follows guidelines
- [ ] Security: no introduced vulnerabilities, inputs validated, secrets not exposed
- [ ] Regression: existing functionality not broken
- [ ] Integration: works with the rest of the system
- [ ] User acceptance: matches expected behavior (for user-facing changes)

**Subagents:** reviewer (code quality), plus verification-specific checks

## §3 The Orchestrator (main agent behavior)

The orchestrator is the main agent itself, guided by system prompts or a loaded skill.
It does NOT implement — it coordinates.

### 3.1 Core behaviors

| Behavior | Rule |
|----------|------|
| **Active questioning** | When requirements are ambiguous, ask — don't guess. Use structured questions (single/multi-select) for clarity. |
| **Uncertainty acknowledgment** | Explicitly state what is unknown, what assumptions are being made, and confidence levels. Never speak with certainty about uncertain things. |
| **Metric-first thinking** | Before any plan, design the verification metrics. "How will we know this is done?" drives everything. |
| **Phase gating** | Never skip a phase. Understanding must be sufficient before planning. Verification must pass before declaring done. |
| **Iteration** | When verification fails, diagnose whether the failure is in understanding, plan, or execution — then loop back to the right phase. |
| **Human collaboration** | For classification decisions (is this done? which approach is preferred? what are the tradeoffs?), involve the user. |

### 3.2 Decision framework

When the orchestrator hits a decision point:

```
Is the answer clear from context/requirements?
├── YES → proceed
└── NO → Is the decision high-impact?
    ├── YES → ask user (structured question with tradeoffs)
    └── NO → make best judgment, flag as assumption
```

### 3.3 Anti-patterns the orchestrator must avoid

- ❌ Jumping to implementation without understanding
- ❌ Being certain about uncertain things
- ❌ Skipping verification because "it looks right"
- ❌ Accepting the user's words literally without probing for real needs
- ❌ Designing tests that only validate the implementation, not the requirement

## §4 Subagent strategy

Subagents are a core mechanism, not a convenience. They enable model tiering,
context isolation, and parallel exploration. Used well, they simultaneously
improve quality and token efficiency.

### 4.1 Why subagents

| Benefit | How it works |
|---------|-------------|
| **Context isolation** | Each subagent gets fresh context. It doesn't carry the main agent's accumulated conversation bloat — critical for long sessions. |
| **Model tiering** | Different phases need different cognitive horsepower. Match model to phase, not one model for everything. |
| **Parallel exploration** | Multiple scouts can explore codebase, web, and documentation simultaneously. |
| **Cognitive offload** | The orchestrator makes decisions. Subagents do detailed work. Neither gets overwhelmed. |

### 4.2 Model tiering

Not all phases need the same model quality. Match the model to the cognitive
demand of the phase:

| Phase | Cognitive demand | Model strategy |
|-------|-----------------|----------------|
| **Understand** | High — synthesis, gap detection, requirement validation | Best available model (e.g., Claude Opus) |
| **Plan** | High — architecture decisions, tradeoff analysis | Best available model |
| **Review / Verify** | High — catching subtle errors, security analysis | Best available model |
| **Execute** | Moderate — translating clear plan into code | Fast/cheap model (e.g., DeepSeek Flash) |
| **Scout (gathering)** | Variable — codebase mapping is mechanical; research synthesis needs quality | Fast for exploration, best for synthesis |

**Principle:** Thinking is expensive; doing is cheap. Concentrate expensive
model capacity on phases where wrong decisions cascade — understanding,
planning, and verification. Use fast models for execution against a clear plan.

### 4.3 Communication discipline

Subagents should communicate with the orchestrator using the simplest possible
terms that preserve the essential meaning. This is not just about saving tokens —
it forces true understanding. You can only simplify what you truly grasp.

**What subagents produce:**
- Key findings, not full transcripts
- Decisions with rationale in one sentence, not paragraphs
- Evidence cited with file:line or URL — not copied verbatim
- "Here's what matters and why" — not "here's everything I found"

**What the orchestrator provides:**
- Self-contained task with all needed context (subagents don't inherit chat history)
- Clear scope: what to investigate, what NOT to investigate
- Expected output format: what the orchestrator needs to make the next decision

### 4.4 Advisor pattern

When the orchestrator is stuck — repeated failures, unable to diagnose why —
spawn an advisor subagent with a strong model.

The advisor receives:
1. **The user's original request — verbatim** (no additions, deletions, reinterpretation)
2. **The orchestrator's current understanding** of the problem and what's been tried
3. **Failure history** and evidence for each failure
4. **The orchestrator's hypothesis** about why it's failing

The advisor's role is diagnosis and redirection — not implementation. It identifies
where the understanding went wrong and suggests a new direction.

**When to use:** same task failed 2+ times; uncertain whether failure is in
understanding, plan, or execution; user frustrated; high-stakes second opinion needed.

**When NOT to use:** first failure (self-diagnose first); trivial mistakes;
problem clearly in execution of a correct plan.

## §5 Scout specialization framework

The current `scout` agent is a generalist. We need specialized scouts for different
understanding tasks.

### 5.1 Scout types

| Scout Type | When to Use | Key Methods |
|------------|-------------|-------------|
| **Codebase scout** | New repo, large codebase, need to find relevant modules | Map structure, trace imports, identify entry points, follow data flow |
| **Web research scout** | Need external knowledge, multiple perspectives, technology evaluation | Broad→narrow search, cross-reference sources, identify conflicting views |
| **Bug-reproduction scout** | Debugging — need to replicate and trace error | Reproduce error state, trace execution path, identify divergence from expected behavior |
| **Requirement-validation scout** | Ambiguous requirements, complex feature | Challenge assumptions, find edge cases, validate against user's actual needs |

### 5.2 Implementation approach

Option A: Separate agent definition files for each scout type (static)
Option B: Single scout agent with mode parameter (runtime customization)
Option C: Base scout + runtime specialization through task description

**Recommendation:** Start with Option C (simplest, works now), evolve to Option B
as we learn which specializations are most valuable.

### 5.3 Scout task templates

**Codebase scout task:**
```
Objective: Map the codebase structure relevant to [feature/bug].
1. Identify key files and modules involved in [area]
2. Trace the data/control flow through [path]
3. Note integration points, dependencies, and constraints
4. Flag anything unusual or risky
```

**Bug-reproduction scout task:**
```
Objective: Replicate and trace the root cause of [bug].
1. Understand the expected behavior: what should happen?
2. Reproduce the error state: what actually happens?
3. Trace execution from trigger to failure point
4. Identify the exact divergence from expected behavior
5. Report: root cause hypothesis with evidence (file:line)
```

## §6 Verification protocol

The verification protocol ensures comprehensive, unbiased validation.

### 6.1 Metric categories

For every task, design metrics across these categories:

| Category | Question | Coding Example | Research Example |
|----------|----------|----------------|-----------------|
| **Correctness** | Does it do what it should? | Unit tests, E2E tests, manual verification | Are conclusions supported by evidence? |
| **Completeness** | Is anything missing? | All acceptance criteria met? Edge cases handled? | Are there unexplored perspectives? |
| **Quality** | Is it well-built? | Maintainability, simplicity, no over-engineering | Are arguments well-structured? Are sources reliable? |
| **Security** | Is it safe? | Input validation, no exposed secrets, no injection | Any dangerous recommendations? |
| **Regression** | Did anything break? | Existing tests pass, manual smoke test | No contradiction with established knowledge? |
| **Integration** | Does it work with the system? | API compatibility, data flow, dependencies | Does it connect with existing knowledge? |

### 6.2 Metric design principle

**Anti-pattern:** Designing verification that only checks the implementation matches itself.
> Example: Writing tests that test what the code does, not what it should do. The test
> passes because it was written to match the implementation, not the requirement.

**Correct approach:** Design verification from requirements and expected behavior FIRST,
before any implementation. Then verify the implementation against those requirements.

### 6.3 Verification workflow

```
1. METRIC DESIGN (during Understanding phase)
   - Define what "done" looks like for each category
   - Create specific, falsifiable checks
   
2. PRE-EXECUTION CHECK (during Planning phase)
   - Verify the plan addresses all metrics
   - Verify the plan doesn't introduce new risks
   
3. POST-EXECUTION VERIFICATION (Verification phase)
   - Run all metric checks
   - Reviewer subagent inspects code
   - Security scan if applicable
   - User acceptance for user-facing changes
   
4. ITERATION (if verification fails)
   - Diagnose: was the failure in understanding, plan, or execution?
   - Loop back to the appropriate phase
   - Re-verify after fixes
```

### 6.4 Verification report format

Every verification should produce a structured report:

```
1. Verdict: PASS / FAIL / NEEDS FIXES
2. Metric results:
   - Correctness: [PASS/FAIL] — [evidence]
   - Completeness: [PASS/FAIL] — [evidence]
   - Quality: [PASS/FAIL] — [evidence]
   - Security: [PASS/FAIL] — [evidence]
   - Regression: [PASS/FAIL] — [evidence]
   - Integration: [PASS/FAIL] — [evidence]
3. Critical findings (must fix) — with file:line evidence
4. Medium findings (should fix) — with evidence
5. Confidence assessment
6. Recommendation: approve / iterate / re-understand
```

## §7 Workflow definition

### 7.1 understand-plan-execute-verify.yaml

```yaml
name: understand-plan-execute-verify
description: >
  Full U→P→E→V workflow with explicit gates.
  Understanding must be sufficient before planning.
  Verification must pass all metrics before completion.
inputs:
  task: ""
  taskType: ""  # bugfix | feature | research | refactor
nodes:
  # === PHASE 1: UNDERSTANDING ===
  - id: understand-codebase
    type: agent
    agent: scout
    task: >
      Codebase understanding for: $workflow.inputs.task
      Map relevant modules, trace data flow, identify integration points.
    dependsOn: []
    condition: "$workflow.inputs.taskType in ['bugfix', 'feature', 'refactor']"

  - id: understand-research
    type: agent
    agent: scout
    task: >
      Research understanding for: $workflow.inputs.task
      Gather multiple perspectives, identify conflicts, assess evidence quality.
    dependsOn: []
    condition: "$workflow.inputs.taskType == 'research'"

  - id: understand-synthesize
    type: manual
    task: >
      Orchestrator synthesizes understanding:
      1. Review scout findings
      2. Clarify requirements with user (grill if needed)
      3. Design verification metrics
      4. Document understanding, assumptions, and metrics
    dependsOn: [understand-codebase, understand-research]
    # This is a manual gate — the orchestrator must confirm before proceeding

  # === PHASE 2: PLANNING ===
  - id: plan
    type: agent
    agent: planner
    task: >
      Create implementation plan for: $workflow.inputs.task
      Based on understanding from previous phase.
    dependsOn: [understand-synthesize]

  - id: review-plan
    type: agent
    agent: reviewer
    task: >
      Review the plan. Does it address all requirements?
      Does it account for constraints? Are verification metrics covered?
    dependsOn: [plan]

  # === PHASE 3: EXECUTION ===
  - id: execute
    type: agent
    agent: executor
    task: >
      Implement according to the approved plan.
    dependsOn: [review-plan]

  # === PHASE 4: VERIFICATION ===
  - id: verify
    type: agent
    agent: reviewer
    task: >
      Comprehensive verification:
      1. Correctness: do tests pass? expected behavior confirmed?
      2. Completeness: all acceptance criteria met?
      3. Quality: maintainable, simple, no over-engineering?
      4. Security: any vulnerabilities introduced?
      5. Regression: existing functionality intact?
      6. Integration: works with the system?
      Report with PASS/FAIL per category.
    dependsOn: [execute]

  - id: verify-user-acceptance
    type: manual
    task: >
      Orchestrator presents verification results to user.
      For user-facing changes: confirm behavior matches expectations.
      If any metric FAILs, loop back to appropriate phase.
    dependsOn: [verify]
```

## §8 Implementation roadmap

### Phase 1: Foundation (this session)
1. **Orchestrator guidance skill** — systematic U→P→E→V framework with subagent strategy,
   model tiering, communication discipline, and advisor pattern.
2. **Verification protocol skill** — six-dimension verification framework with metric design principles.
3. **Advisor agent** — high-model diagnostic agent for when orchestrator is stuck.
4. **Enhanced grill-me-requirements** — expected behavior exploration, verification metrics, tradeoff surfacing.
5. **Architecture document** — full system design in wiki.

### Phase 2: Workflow automation (next)
4. **U→P→E→V workflow YAML** — implement the workflow definition with phase gating.
5. **Scout specialization** — create specialized scout task templates; evaluate whether
   separate agent definitions are needed.

### Phase 3: Advanced (later)
6. **Runtime scout customization** — parameterized scout modes.
7. **Verification agent** — dedicated verification subagent with metric execution.
8. **Iteration analytics** — track which phases cause failures to improve the system.

## §9 Open questions

1. **How strict should gates be?** For trivial tasks, forcing all 4 phases is overhead.
   Need a "task complexity classifier" that determines whether full U→P→E→V is warranted.
2. **Verification metric design — who does it?** The orchestrator? A specialized agent?
   The user? Currently proposing orchestrator + user collaboration.
3. **Scout parallelism vs sequencing?** Multiple scouts can run in parallel (codebase +
   web research), but their findings must be synthesized before planning.
4. **Where does the orchestrator guidance live?** System prompt? Loaded skill? Workflow?
   Proposal: a skill loaded at session start for complex tasks, with workflow as automation.

## See also

- [subagent system](subagent-system.md)
- [workflows](workflows.md)
- [workflow extension](workflow-extension.md)
- [agent agents](agent-agents.md)
- [skills](skills.md)
