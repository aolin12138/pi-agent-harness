# Workflow Creator Extension Plan (Draft v0.2)

## Context
You want `/workflow:create` to become an interactive workflow architect that:

1. **Discusses logic with you first** so requirements and flow are aligned before generation.
2. **Auto-creates a full workflow draft** once alignment is reached.
3. Produces node design where each node is independent and meaningful.
4. **Merges nodes** when they are repetitive or have large context overlap.
5. Builds a valid DAG that matches business logic.
6. Reuses existing agents from Agent Manager directories, and creates missing agents when needed.
7. Saves workflow config under **`.pi/workflows`**.
8. Opens a web review after draft creation where you can give feedback and manually edit.
9. Supports a **visual DAG-style editor** (not just a text plan review).

Current baseline (already implemented):
- `workflow-orchestrator` has `/workflow:list`, `/workflow:analyze`, `/workflow:run`, `/workflow:inspect`, and `run_workflow` tool.
- There is only a static prompt template `prompts/create-workflow.md` (no interactive creator command).
- Agent discovery utilities already exist in extension code.
- Plannotator event API can be reused for browser-based review flows.
- Current command quality/reliability has not been formally audited yet; this must be done first before relying on them for creation/edit UX.
- `/workflow:inspect` currently focuses on run-state JSON inspection, not a DAG visual editor.

---

## Approach
Implement workflow creation as a two-surface experience:

- **CLI orchestrator command** for requirements clarification, generation, validation, save.
- **Web DAG editor/review** for visual node/edge edits and iterative feedback.

Add an upfront reliability pass:
- audit existing workflow commands (`list/analyze/run/inspect`) for correctness and UX gaps.
- fix critical gaps first so creation + visualization features build on trustworthy foundations.

### 1) `/workflow:create [goal]` command flow

#### Phase A — Alignment discussion (required)
- Gather goal + constraints via editor and targeted follow-up questions.
- Run structured clarification rounds until no critical ambiguity remains.
- Present compact “alignment contract” summary:
  - objective
  - required outputs
  - constraints
  - node granularity rules
  - assumptions
- Explicit confirmation required before draft generation.

#### Phase B — Auto-draft generation
- Generate structured node plan (JSON) first, then convert to YAML.
- Enforce node quality rules during synthesis:
  - every node has a distinct purpose
  - merge repetitive nodes
  - merge nodes with major context overlap
  - keep dependencies minimal but logically correct

#### Phase C — Validation + persistence
- Validate DAG deterministically:
  - unique node IDs
  - known dependencies only
  - cycle-free topology
  - dependency consistency with inputRefs
- Save to `.pi/workflows/<name>.yaml`.
- Run existing `analyzeWorkflow` before review launch.

### 2) Agent resolution strategy
- For each agent node, match required capability against discovered agents.
- Reuse matching agents first.
- If missing, prompt user with **3 explicit choices per missing agent**:
  1. **Yes (current only)** — approve creation for this missing agent only.
  2. **Yes to all (this workflow)** — approve creation for all remaining missing agents in this workflow.
  3. **No (I’ll create manually)** — skip auto-create; keep unresolved placeholder and continue.
- Auto-create only for approved items via Agent Manager flow, then bind to nodes.
- Re-run workflow validation after agent injection.

### 3) Visual DAG review/editor (workflow-specific web UI)
- Open a browser UI after draft creation.
- UI must show interactive DAG (nodes + edges), not only markdown review.
- User can:
  - edit node fields
  - add/remove nodes
  - add/remove dependencies
  - edit task text and inputRefs
  - edit YAML directly (advanced mode)
- On save/approve, write back YAML and return review result to command.
- If feedback/reject, command loops and regenerates/patches workflow accordingly.

### 4) New visualization command
- Add **`/workflow:visualize <name>`** to open the same DAG UI for an existing workflow.
- Purpose: visualize, edit, and provide feedback even after creation.
- Keep `/workflow:inspect` for run records; do not overload it with editor responsibilities.

### 5) Review loop behavior
- Keep same workflow filename across revisions.
- Diff each revision (node-level + YAML-level) before resubmission.
- Permit manual web edits as source-of-truth if user chooses manual mode.
- If manual edits conflict with inferred requirements, or if there is ambiguity/confusion, pause and ask the user targeted clarification questions **before** resubmitting the DAG/workflow.

---

## Files to modify
- `agent/extensions/workflow-orchestrator/index.ts`
  - audit and harden existing workflow commands (`list/analyze/run/inspect`)
  - add `/workflow:create`
  - add `/workflow:visualize <name>`
  - add clarification loop
  - add node-merge heuristics
  - add agent matching + missing-agent create path
  - add save + validate + review loop orchestration
- `agent/extensions/workflow-orchestrator/README.md`
  - document `/workflow:create` and review loop
- `agent/prompts/create-workflow.md`
  - strengthen rules for independent nodes + merge conditions

### New workflow UI assets (proposed)
- `agent/extensions/workflow-orchestrator/workflow-editor.html`
- `agent/extensions/workflow-orchestrator/workflow-editor.ts` (or generated JS bundle)
- `agent/extensions/workflow-orchestrator/workflow-events.ts`
- `agent/extensions/workflow-orchestrator/server.ts` (or reuse existing Plannotator server/event plumbing with new action)

---

## Reuse
- Reuse from workflow-orchestrator:
  - `loadWorkflows`, `loadAgents`, `analyzeWorkflow`, ref resolution patterns
- Reuse from agent-manager:
  - model-driven JSON generation + parse pattern
  - confirmation gates and staged apply flow
- Reuse from plannotator extension package:
  - browser session lifecycle pattern
  - shared event request/response style
  - persisted review status structure

---

## Confirmed decisions
1. **Visual DAG editor scope (v1):** full flexibility — node CRUD, edge editing, field editing, and YAML sync/editor.
2. **Manual web edit precedence:** manual edits are source-of-truth.
   - Exception: if conflicts/ambiguity are detected, command must discuss with user before resubmission.
3. **Missing-agent creation UX:** per-missing-agent approval with three options:
   - yes (current only)
   - yes to all remaining for this workflow
   - no (user will create manually)

---

## Steps
- [ ] Audit existing workflow extension command quality and document/fix critical reliability issues first.
- [ ] Add `/workflow:create` command scaffold and user flow states (align → generate → validate → review).
- [ ] Add `/workflow:visualize <name>` command scaffold that opens the DAG editor for existing workflows.
- [ ] Implement strict clarification/alignment contract before generation.
- [ ] Implement node synthesis with merge heuristics (repetition/context-overlap).
- [ ] Implement DAG validation (IDs, deps, cycle detection, inputRef consistency).
- [ ] Implement agent matching + per-missing-agent approval path (yes current / yes all / no manual).
- [ ] Save workflow to `.pi/workflows/<name>.yaml` and run analyzer.
- [ ] Build workflow-specific web DAG review/editor with full node/edge/field flexibility and YAML sync.
- [ ] Implement reject/feedback/manual-edit revision loop with conflict clarification gate.
- [ ] Update docs + examples.

---

## Verification
- [ ] Existing workflow commands pass reliability checks after hardening (no critical regressions in list/analyze/run/inspect).
- [ ] `/workflow:create` does not generate until alignment confirmation.
- [ ] Generated nodes are independent and merge rules are respected.
- [ ] Generated DAG is valid and analyzable.
- [ ] Workflow saves to `.pi/workflows`.
- [ ] Existing agents are reused where suitable.
- [ ] Missing-agent approval UI offers exactly 3 options (yes current / yes all / no manual) and behaves correctly.
- [ ] Web review opens automatically after draft creation.
- [ ] `/workflow:visualize <name>` opens the DAG UI for existing workflows.
- [ ] DAG can be edited visually (full CRUD + edge mgmt + field editing) and persisted back to YAML.
- [ ] If manual edits create ambiguity/conflict, user clarification is requested before resubmission.
- [ ] Feedback rejection triggers revision loop with same workflow filename.
