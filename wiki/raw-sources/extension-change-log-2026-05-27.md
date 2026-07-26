# Extension change log — 2026-05-27

## Purpose
Reference log before extension replacement/update, so behavior changes can be validated after updating Pi.

## Current active package config (before change)
From `C:/Users/User/.pi/agent/settings.json`:
- `npm:pi-web-access`
- `npm:@plannotator/pi-extension`
- `npm:pi-prompt-autoresearch`
- `git:github.com/edxeth/pi-subagents`

## External extension findings

### 1) `edxeth/pi-tasks`
- Purpose: session-scoped task system for Pi (tools + widget + persistent storage).
- Main tools: `task_create`, `task_list`, `task_get`, `task_update`, `task_batch`.
- UI/commands: `/tasks`, `/tasks-clear-completed`, `Ctrl+Alt+T` widget cycle.
- Storage model: `~/.pi/tasks/<sessionKey>/...` with lock + atomic write semantics.
- Notes: includes mention of subagent-aware token accounting.
- Fit: good if you want explicit task tracking discipline.
- Risk/overlap: may overlap with local `task-progress` style workflow.

### 2) `@eko24ive/pi-ask`
- Purpose: structured clarification flow (`ask_user`) with rich interactive UI.
- Features: single/multi-select, notes, review/submit flow, replay commands (`/answer`, `/answer:again`, `/ask:replay`, `/ask-settings`).
- Install: npm or git.
- Fit: strong candidate for option/requirements questioning.
- Risk/overlap: could overlap with current grill-me / `pick_option` style flows.

### 3) `@micuintus/llm-wiki`
- Purpose: lightweight skill-based LLM wiki pattern (minimal infra, markdown-centric).
- Provides skill + references rather than heavy runtime extension.
- Fit: optional if you want Karpathy-style wiki curation conventions.
- Risk/overlap: conceptual overlap with local wiki/PKB workflows.

## Local customization findings (critical for post-update checks)

### A) Local `pi-subagents` customization
Location:
- `C:/Users/User/.pi/agent/git/github.com/edxeth/pi-subagents`

Modified files:
- `src/subagents/index.ts`
- `src/subagents/mux.ts`

Behavior-level customizations observed:
- custom frontmatter parsing behavior for agent definitions
- relaxed tool validation/allowlist for custom extension tools
- planner launch adjustments (`--plan`, planner-related env vars)
- Windows/PowerShell/WezTerm launch compatibility improvements
- launch command/env prefix/escaping changes

Upstream drift/risk:
- local clone behind upstream significantly (~44 commits observed during audit)
- upstream refactor deletes/restructures touched files
- **update conflict risk: HIGH**

### B) Local Plannotator customization
Location:
- `C:/Users/User/AppData/Roaming/npm/node_modules/@plannotator/pi-extension/index.ts`

Observed custom behavior:
- env-gated planner flow controls:
  - `PI_PLANNOTATOR_STAY_IN_PLANNING_AFTER_APPROVAL`
  - `PI_PLANNOTATOR_DISABLE_AUTO_CONTINUE`
- intended effect: keep planner in planning scope and suppress forced auto-continue.

Coupling note:
- local subagent customization appears to set these env vars for planner launches.

Risk:
- **functional risk MEDIUM** on update (custom behavior may be lost if patch not re-applied).

## Post-change validation checklist
After extension replacement + Pi update:

1. Verify package list in `agent/settings.json` is exactly intended.
2. Launch Pi and confirm no extension load errors.
3. Validate todo flow:
   - task tools available and callable
   - widget/commands behave (`/tasks` etc.)
4. Validate options flow:
   - `ask_user` invocation works
   - `/ask-settings` and replay commands register
5. Validate wiki flow:
   - llm-wiki skill is discoverable/loadable
6. If keeping custom planner behavior:
   - planner stays in planning scope after approval
   - auto-continue suppression still works when expected
7. Re-check subagent launches in your shell/mux setup (especially non-mux + PowerShell/WezTerm contexts).

## Rollback notes
- Back up current `agent/settings.json` before replacement.
- Keep patch copies for any custom subagent/plannotator behavior you rely on.
