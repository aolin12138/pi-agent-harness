---
title: "pi-web — Build History"
type: concept
updated: 2026-05-31
sources:
  - ~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-27T06-18-00-110Z_019e6815-322e-7256-b07e-bab68589457b.jsonl
  - C:/Users/User/.pi/pi-web/README.md
tags: [pi-web, ui, preact, vite, build-log]
---

# pi-web — Build History

Modern web UI for the Pi coding agent, built in a single long session on 2026-05-27. Built from scratch using Preact + Vite + Zustand.

## Session stats

| Metric | Value |
|--------|-------|
| Session | 2026-05-27 06:18 UTC |
| Size | 7.0 MB JSONL |
| User messages | 150 |
| Tool calls | ~1,235 total |
| Files written | 61 (31 unique) |
| Files edited | 350 edits across 40 files |
| Subagents | 5 spawns (2 planner, 1 scout, 1 reviewer, 1 executor) |
| Model | gpt-5.3-codex (azure-openai-responses) |

## Build sequence

1. **Scaffold**: Started with tau extension installation, created utility scripts (tau-dev-start, tau-dev-sync, tau-dev-promote, tau-dev-status for both bash and PowerShell)
2. **Foundation**: package.json, vite.config.ts, tsconfig.json, index.html, main.tsx entry point
3. **Stores**: chatStore.ts (messages, toolExecutions, streaming state), uiStore.ts (sidebar, settings, theme), sessionStore.ts (session list, mirror mode)
4. **Services**: websocket.ts (WS client with reconnect), rpc-handler.ts (Pi RPC event dispatch), markdown.ts (marked-based renderer)
5. **Core components**: App.tsx (root layout, keyboard shortcuts, WS wiring), Header.tsx (model picker, thinking toggle), ChatArea.tsx (messages + input), MessageList.tsx (memoized rendering)
6. **Tool cards**: ToolCard.tsx (collapsible with diff view)
7. **Sidebar**: SessionSidebar.tsx (project/session tree, subagent nesting, search)
8. **Panels**: AskPanel.tsx (interactive Q&A), TaskBoard.tsx (checklist nodes), SubagentList.tsx (grouped status)
9. **UX**: CommandPalette.tsx (Ctrl+K overlay), SettingsPanel.tsx (theme grid), ModelPicker.tsx (searchable dropdown), SlashCommands.tsx
10. **Styling**: global.css with 6 themes via CSS custom properties (most-edited file: 68 edits)
11. **Extension server**: extensions/server.ts for standalone operation
12. **Sync scripts**: sync-tasks.mjs, sync-harness-tasks.mjs for task synchronization
13. **Documentation**: README.md

## Most iterated files

| File | Edits | Why |
|------|-------|-----|
| `global.css` | 68 | Theming, responsive design, layout refinements |
| `App.tsx` | 43 | Root component — keyboard shortcuts, layout, WS wiring |
| `MessageList.tsx` | 29 | Message rendering and memoization |
| `rpc-handler.ts` | 23 | Event dispatch logic |
| `ChatArea.tsx` | 17 | Input handling, slash commands, image attachments |

## Dev tooling created

| Script | Purpose |
|--------|---------|
| `tau-dev-start.sh/.ps1` | Start tau dev environment |
| `tau-dev-sync.sh/.ps1` | Sync pi-web build to tau |
| `tau-dev-promote.ps1` | Promote dev build to production |
| `tau-dev-status.ps1` | Check dev environment status |
| `sync-tasks.mjs` | Sync task state |
| `sync-harness-tasks.mjs` | Sync harness task state |
| `check_subs.py` | Subprocess health check |

## Architecture decisions made during build

- Preact over React for bundle size (~3KB vs ~40KB)
- Zustand over Redux for minimal boilerplate
- CSS custom properties for theming (no CSS-in-JS runtime)
- WebSocket transport for streaming with reconnect
- `marked` for markdown (no React dependency)

## See also

- [project overview](../context/overview.md)
- [architecture](../context/architecture.md)
- [extensions](extensions.md)
