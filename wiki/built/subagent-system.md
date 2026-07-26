---
title: "Subagent System — Investigation and Implementation"
type: concept
updated: 2026-05-31
sources:
  - ~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-12T03-38-17-560Z_019e1a43-9657-713c-b48e-a3ff7b67743a.jsonl
tags: [subagents, delegation, agents, research]
---

# Subagent System — Investigation and Implementation

Investigated subagent patterns across Claude, Codex, and Pi, then implemented agent definitions and a plan-execute-review workflow chain.

## Session stats

| Metric | Value |
|--------|-------|
| Session | 2026-05-12 03:38 UTC |
| Size | 5.1 MB |
| User messages | 113 |
| Tool calls | ~365 total |
| Files written | 18 |
| Model | gpt-5.3-codex |

## Research scope

Investigated:
- How Claude Code uses subagents (task-specific delegation)
- How Codex CLI uses subagents
- Pi's current subagent implementation (subagent tool, agent definitions, metadata fields)
- Comparison of delegation patterns across platforms

## Artifacts produced

| File | Purpose |
|------|---------|
| `planner.md` | Agent definition: creates implementation plans |
| `executor.md` | Agent definition: implements approved plans |
| `reviewer.md` | Agent definition: reviews implementation quality |
| `plan-execute-review.chain.md` | Workflow chain: plan → execute → review |
| `subagent-routing.md` | Routing logic for subagent delegation |
| `enable-subagent-autopilot.md` | Autopilot configuration |
| `SKILL.md` | Subagent progressive-disclosure skill |
| `.wezterm.lite` | Terminal configuration |

## Key findings

- Claude Code uses subagents as isolated task executors with fresh context
- Pi's subagent system uses agent definitions (markdown files) with metadata for execution mode, tool access, and context policy
- The plan→execute→review chain pattern emerged as the core delegation workflow
- Subagents benefit from `fresh_chat_needs_full_brief` context (self-contained tasks) rather than inheriting parent chat

## See also

- [agent agents](agent-agents.md)
- [workflows](workflows.md)
- [skills](skills.md)
