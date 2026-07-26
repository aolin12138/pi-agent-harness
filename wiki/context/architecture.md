---
title: "Architecture"
type: concept
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/pi-web/README.md
  - C:/Users/User/.pi/PLAN-pkb-llm-wiki.md
tags: [architecture, subsystems, integration]
---

# Architecture

How pi-web, extensions, workflows, agents, and skills fit together in the Pi ecosystem.

## System diagram

```
┌──────────────────────────────────────────────────┐
│                    Browser                        │
│  ┌────────────────────────────────────────────┐  │
│  │              pi-web (Preact)                │  │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐  │  │
│  │  │Chat  │ │Tools │ │Sess. │ │Settings  │  │  │
│  │  │Area  │ │Cards │ │Sideb.│ │Panel     │  │  │
│  │  └──────┘ └──────┘ └──────┘ └──────────┘  │  │
│  └──────────────┬─────────────────────────────┘  │
│                 │ WebSocket                       │
└─────────────────┼────────────────────────────────┘
                  │
┌─────────────────┼────────────────────────────────┐
│            Pi Agent Core                          │
│  ┌──────────────┴──────────────────────────────┐ │
│  │           HTTP + WS Server                   │ │
│  └──────────────┬──────────────────────────────┘ │
│                 │                                 │
│  ┌──────────────┴──────────────────────────────┐ │
│  │         Agent Runtime                        │ │
│  │  ┌────────┐ ┌────────┐ ┌────────────────┐   │ │
│  │  │Skills  │ │Agents  │ │Extensions      │   │ │
│  │  └────────┘ └────────┘ └────────────────┘   │ │
│  │  ┌────────┐ ┌────────┐ ┌────────────────┐   │ │
│  │  │Tools   │ │Session │ │Workflows       │   │ │
│  │  └────────┘ └────────┘ └────────────────┘   │ │
│  └─────────────────────────────────────────────┘ │
│                                                  │
│  ┌─────────────────────────────────────────────┐ │
│  │         Storage                              │ │
│  │  Sessions (JSONL) │ Tasks │ Wiki (MD)        │ │
│  └─────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

## Integration points

| Boundary | Mechanism |
|----------|-----------|
| pi-web ↔ Agent | WebSocket (streaming messages, tool cards, RPC) |
| Extensions ↔ Agent | Lifecycle hooks (turn_end, tool_result, session_shutdown) |
| Skills ↔ Agent | Markdown files loaded on-demand by task matching |
| Agents ↔ Agent | Subagent tool (spawn with agent definition + task) |
| Workflows ↔ Agent | YAML definitions executed via /run-workflow |
| Wiki ↔ Sessions | Session recipe: JSONL → extract → compile → markdown |

## Data flow

1. User sends message via pi-web → WebSocket → Agent runtime
2. Agent loads PROFILE.md + MEMORY.md (user model) at session start
3. Agent processes → loads skills as needed → calls tools
4. Tools may spawn subagents (planner, executor, scout, advisor, etc.)
5. All events recorded to session JSONL
6. Post-session: wiki-maintenance skill extracts project knowledge → wiki pages
7. Post-session: user signals extracted → `~/.pi/user/memory/`

## See also

- [project overview](overview.md)
- [pi-web](../built/pi-web.md)
- [PKB plan](../built/pkb-plan.md)
- [extensions](../built/extensions.md)
