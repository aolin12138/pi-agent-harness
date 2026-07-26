---
title: "Pi Configuration Project Overview"
type: concept
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/pi-web/README.md
  - C:/Users/User/.pi/PLAN-pkb-llm-wiki.md
tags: [overview, project]
---

# Pi Configuration Project Overview

The `.pi` project is the configuration and customization layer for the Pi coding agent. It contains extensions, workflows, subagent definitions, skills, a web UI (pi-web), and supporting infrastructure.

## Directory layout

```
~/.pi/
├── agent/              # Agent runtime config
│   ├── agents/         # Subagent definitions (.md)
│   ├── sessions/       # Session JSONL files (per-project dirs)
│   ├── extensions/     # Pi extensions (TypeScript)
│   ├── workflows/      # Workflow YAML definitions
│   └── wiki/           # Global core memory wiki
├── pi-web/             # Preact + Vite web UI (separate git repo)
├── extensions/         # User extensions
├── tasks/              # Persistent task storage
├── llm-wiki/           # This knowledge base
├── bin/                # Utility scripts
├── backups/            # Configuration backups
└── tau-dev/            # Tau development instance
```

## Key subsystems

| Subsystem | Location | Description |
|-----------|----------|-------------|
| pi-web | `pi-web/` | Preact + Vite web UI with streaming, tool cards, themes, sessions sidebar |
| Extensions | `agent/extensions/`, `extensions/` | TypeScript extensions hooking into Pi lifecycle |
| Workflows | `agent/workflows/` | YAML-defined multi-step workflows (ingest, audit, etc.) |
| Subagents | `agent/agents/` | Markdown agent definitions (executor, planner, reviewer, scout, wiki, chatter) |
| Skills | `agent/skills/`, `.agents/skills/` | Skill definitions providing specialized guidance |
| MCP Server | (planned) | MCP server for tool integration |
| PKB / LLM Wiki | `llm-wiki/` | This knowledge base — project memory and behavioral patterns |

## Sessions

Session JSONL files are stored at `~/.pi/agent/sessions/--C--Users-User-.pi--/` (74 files as of 2026-05-31, spanning Apr 22–May 31). Each session captures the full message tree, tool calls, subagent spawns, and custom events.

## See also

- [pi-web overview](../built/pi-web.md)
- [architecture](architecture.md)
- [PKB plan](../built/pkb-plan.md)
