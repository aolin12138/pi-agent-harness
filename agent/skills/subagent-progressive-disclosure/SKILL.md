---
name: subagent-progressive-disclosure
description: Progressive-disclosure delegation policy for subagents. Forces tool-first discovery and active delegation for complex/independent tasks.
---

# Subagent Progressive Disclosure Policy

Use this policy whenever subagent tools are available.

## Goal
Delegate the right work to the right subagent with predictable behavior.

## Capability check (required)
Before delegating, verify subagent tools are available in the current tool list.
If unavailable, continue locally and state that delegation is unavailable.

## Progressive disclosure protocol (required)
For tasks that are complex, multi-step, specialized, or parallelizable:

1. Call `subagents_list` to discover available named agents.
2. Match requested work to agent descriptions.
3. Pick the smallest valid delegation plan:
   - single specialist agent when one role is enough
   - sequential dependent flow when outputs depend on prior steps
   - parallel launches only for independent work
4. Launch using `subagent` with explicit task translation for each child.
5. Use `subagent_wait` / `subagent_join` only when synchronization is required.
6. Return concise synthesized results with file paths/artifacts.

## Routing rules (strict)
- Planning/scoping/architecture -> MUST delegate to `planner` when available.
- Implementation with an approved plan -> MUST delegate to `executor` when available.
- Review/audit/QA/risk check -> MUST delegate to `reviewer` when available.
- End-to-end requests -> SHOULD run plan -> execute -> review sequence.

## Chain/retry behavior
For plan -> execute -> review:
1. Run planner
2. Run executor with planner output
3. Run reviewer with plan + implementation output
4. If reviewer verdict is FAIL, run one corrective execute->review loop.
5. If still FAIL, escalate clearly with blockers and next options.

## Context rules
- Default child context: fresh/isolated.
- Use fork/inherited context only when explicitly required.
- Child task must be self-contained in isolated context.

## Ownership rules
- Parent must not redo delegated work while child owns it.
- After async launches, only do non-overlapping parent work.
- If no safe independent work exists, wait/yield for child result.

## Output contract
When returning delegated outcomes, include:
1. Delegation decisions (which agent(s), why)
2. Result summary per child
3. Output/artifact file paths
4. Clear next action or final answer
