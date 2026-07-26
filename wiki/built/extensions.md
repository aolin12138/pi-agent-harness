---
title: "Extensions"
type: concept
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/extensions/
  - C:/Users/User/.pi/agent/extensions/
  - .codegraph status (1,485 nodes, 3,872 edges)
tags: [extensions, plugin-system]
---

# Extensions

Pi's extension system allows hooking into the agent lifecycle via TypeScript modules.

## Installed extensions (npm packages)

| Extension | Location | Purpose |
|-----------|----------|---------|
| pi-web server | `extensions/` | HTTP server for pi-web UI |
| pi-playwright | `agent/npm/node_modules/pi-playwright/` | Browser automation via Playwright |
| pi-ask | `AppData/Roaming/npm/node_modules/@eko24ive/pi-ask/` | Interactive user clarification |
| llm-wiki | `AppData/Roaming/npm/node_modules/@micuintus/llm-wiki/` | LLM-curated personal knowledge base |

## Custom extensions (agent/extensions/)

Discovered via CodeGraph analysis. These are TypeScript extensions in the agent directory.

| Extension | File | Symbols | Purpose |
|-----------|------|---------|---------|
| agent-manager | `agent-manager/index.ts` | 66 | Agent creation and management |
| workflow-orchestrator | `workflow-orchestrator/index.ts` | 55 | Multi-step workflow orchestration |
| adaptive-thinking | `adaptive-thinking.ts` | 8 | Adaptive thinking level adjustment |
| snake | `snake.ts` | 37 | Snake game (fun extension) |

## Disabled extensions (`_disabled-2026-05-27/`)

Extensions disabled on 2026-05-27 during the extension replacement.

| Extension | File | Symbols | Reason |
|-----------|------|---------|--------|
| grill-me-ui | `grill-me-ui/index.ts` | 7 | Replaced by pi-ask extension |
| task-progress | `task-progress.ts` | 19 | Replaced by built-in task system |
| ~~pkb-wiki~~ | ~~`pkb-wiki.ts`~~ | ~~34~~ | **Deleted 2026-05-31** — replaced by LLM Wiki extension |

## Extension hooks

| Hook | Trigger |
|------|---------|
| `turn_end` | After each agent turn completes |
| `tool_result` | When a tool returns a result |
| `session_shutdown` | When a session ends |
| Compaction hooks | Before/after context compaction |

## Extension changelog

See `extension-change-log-2026-05-27.md` for the May 27 extension replacement.

## See also

- [project overview](../context/overview.md)
- [pi-web](pi-web.md)
- [skills](skills.md)
