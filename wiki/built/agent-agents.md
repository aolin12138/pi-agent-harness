---
title: "Subagent Agents"
type: reference
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/agent/agents/
tags: [agents, subagents, delegation]
---

# Subagent Agents

Subagent definitions stored as markdown files in `~/.pi/agent/agents/`. Each agent has a specific role, tool set, and execution mode.

## Agent roster

| Agent | Role | Tool return | Runs as | Context | Completion |
|-------|------|-------------|---------|---------|------------|
| chatter | Motivational companion | later_message | visible_terminal | fresh_chat_needs_full_brief | exits_automatically |
| chatter2 | Supportive conversational coach | later_message | visible_terminal | fresh_chat_needs_full_brief | exits_automatically |
| executor | Implements approved plans | wait_here | hidden_process | fresh_chat_needs_full_brief | exits_automatically |
| planner | Creates implementation plans | wait_here | hidden_process | fresh_chat_needs_full_brief | exits_automatically |
| reviewer | Reviews implementation quality | wait_here | hidden_process | fresh_chat_needs_full_brief | exits_automatically |
| scout | Investigates topics/codebases | later_message | hidden_process | fresh_chat_needs_full_brief | exits_automatically |
| advisor | Diagnoses failures and suggests new direction when orchestrator is stuck | wait_here | hidden_process | fresh_chat_needs_full_brief | exits_automatically |

## Delegation patterns

| Pattern | When to use |
|---------|-------------|
| planner → executor → reviewer | Full implementation pipeline |
| scout (parallel) | Multi-angle investigation |
| single scout | Targeted codebase research |
| advisor | When orchestrator is stuck — diagnosis and redirection |

## See also

- [project overview](../context/overview.md)
- [skills](skills.md)
