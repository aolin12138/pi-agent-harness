---
title: "Wiki Graph Visualization"
type: concept
updated: 2026-06-02
sources:
  - ~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-31T12-32-57-390Z_019e7e05-ea2e-7bdc-9854-8467f53629be.jsonl
  - C:/Users/User/.pi/pi-web/src/components/WikiGraphPanel.tsx
  - C:/Users/User/.pi/pi-web/extensions/server.ts
  - C:/Users/User/.pi/pi-web/tests/wiki-graph.spec.ts
tags: [wiki-graph, d3, visualization, pi-web, built]
---

# Wiki Graph Visualization

Interactive Obsidian-style knowledge graph for the LLM Wiki, integrated into pi-web. Shows wiki page relationships as a force-directed graph using D3.js force simulation rendered on Canvas2D.

## Quick facts

| Attribute | Value |
|-----------|-------|
| Framework | D3.js `forceSimulation` + Canvas2D (no library wrapper) |
| Data source | `parseWikiGraph()` in `extensions/server.ts` |
| API endpoint | `GET /api/wiki-graph` |
| Page content | `GET /api/wiki-page?path=...` |
| UI component | `src/components/WikiGraphPanel.tsx` |
| Store toggles | `uiStore.wikiGraphOpen` / `wikiAvailable` |
| Tests | 18 Playwright E2E (`tests/wiki-graph.spec.ts`) — all passing |
| Built | 2026-05-31 session (2.1 MB JSONL) |

## Architecture

```
Browser (pi-web)                    Extension Server
┌────────────────────────┐         ┌───────────────────────┐
│ WikiGraphPanel         │  GET    │ /api/wiki-graph       │
│  ┌──────────────────┐  │────────→│  parseWikiGraph()     │
│  │ Canvas2D render  │  │  JSON   │  ┌─────────────────┐  │
│  │ D3 forceSim      │  │←────────│  │ scan llm-wiki/  │  │
│  │ zoom/pan/drag    │  │         │  │ scan patterns/  │  │
│  │ detail panel     │  │  GET    │  │ extract links   │  │
│  │ audit dashboard  │  │────────→│  └─────────────────┘  │
│  └──────────────────┘  │  MD     │ /api/wiki-page        │
│                        │←────────│  readFile(pagePath)   │
└────────────────────────┘         └───────────────────────┘
```

## Graph model

### Cell nucleus layout

One root node per wiki source sits at the center. All pages in that wiki link to their root and orbit at a fixed radius (220px). This creates a clear visual separation between the main wiki (`~/.pi/llm-wiki/`) and the agent wiki (`~/.pi/agent/llm-wiki/patterns/`).

### Force configuration

| Force | Value | Purpose |
|-------|-------|---------|
| `forceLink` | `distance: 60` | Keeps linked pages together |
| `forceManyBody` | `strength: -50` (cross-category only) | Light separation between wikis |
| `forceRadial` | `radius: 220px` from root | Orbits pages around wiki root |
| Regular page repulsion | Zero | Prevents page drift |

Regular pages have zero repulsion between each other — only cross-category repulsion (`-50`) separates the two wiki sources.

### Node schema

```ts
interface WikiNode {
  id: string;          // page path (e.g., "built/subagent-system.md")
  path: string;        // filesystem path
  title: string;       // display title (from frontmatter or filename)
  type: string;        // concept, reference, decision, pattern, etc.
  folder: string;      // top-level folder (built, projects, patterns, etc.)
  updated: string;     // last modified date
  tags: string[];      // from frontmatter
  linkCount: number;   // number of outgoing links
  color: string;       // computed from folder
  source: "pi" | "agent memory";  // which wiki
}
```

## Features

### Root-level filters
Three filter pills toggle visibility: **All** (both wikis), **Wiki** (main `~/.pi/llm-wiki/`), **Agent** (agent memory patterns). Filtering removes nodes from the simulation without restarting it.

### Zoom and pan
- Scroll to zoom (clamped 0.1x–5x)
- Drag background to pan
- Works with trackpad pinch/scroll

### Node interaction
- **Single click + drag**: Move node (4px drag threshold prevents accidental moves)
- **Double click**: Open detail panel with full markdown content fetched from `/api/wiki-page`
- **Relative offset drag**: Node follows cursor position relative to click point (no snap)

### Detail panel
Right-side panel showing:
- Page title, type badge, folder path
- Markdown rendered to HTML (headers, bold, code blocks, links, lists, blockquotes)
- Link count
- Close button

### Audit dashboard
Toggle-able dashboard displaying:
- **Broken links**: Page links where target doesn't exist in the graph
- **Stale pages**: Pages not updated in >30 days
- **Type breakdown**: Count of pages by type (concept, reference, decision, etc.)
- **Node/link totals**: Aggregate graph statistics

## Server-side parsing

`parseWikiGraph()` in `extensions/server.ts`:
1. Scans `~/.pi/llm-wiki/` for all `.md` files (recursive)
2. Scans `~/.pi/agent/llm-wiki/patterns/` for agent memory patterns
3. Extracts frontmatter (title, type, tags, updated)
4. Parses markdown links `](*.md)` to build link graph
5. Computes colors by folder, link counts per node
6. Returns `{ available, nodes, links, stats: { brokenLinks, staleNodes, totalNodes, totalLinks, typeCounts } }`

### Agent wiki discrimination
Uses `startsWith(agentWikiDir)` rather than `includes("agent")` to avoid false positives (e.g., `agent-agents.md` in main wiki was incorrectly classified before this fix).

## Rendering

Uses raw D3 `forceSimulation` driving a Canvas2D draw loop. The `force-graph` package was abandoned early due to a silent rendering bug.

- **Continuous draw**: `requestAnimationFrame` loop runs permanently while overlay is open
- **Refs over closures**: `selectedNode` and `connectedIds` stored in refs to prevent stale closure capture in `draw()`
- **Named event handlers**: Cleanup on filter switches prevents listener accumulation
- **6px minimum node radius**: Ensures zero-link pages are visible and clickable

## Test coverage

18 Playwright E2E tests in `tests/wiki-graph.spec.ts` covering:

| Category | Tests |
|----------|-------|
| API | Mock data validity, broken link detection, stale node detection, patterns folder presence |
| UI toggle | Button visibility (with/without data), open/close overlay, button hidden on API failure |
| Rendering | Canvas dimensions, node/link counts in stats |
| Interaction | Double-click detail, drag node movement, filter switching |
| Edge cases | Escape closes, rapid open/close stability, available=false hides button |

## See also

- [pi-web overview](C:/Users/User/.pi/pi-web/.wiki/overview.md)
- [pi-web architecture](C:/Users/User/.pi/pi-web/.wiki/architecture.md)
- [pi-web build history](C:/Users/User/.pi/pi-web/.wiki/build-history.md)
- [wiki version control](wiki-version-control.md)
- [LLM Wiki documentation](https://github.com/eko24ive/llm-wiki)
