# Pi Configuration Project — Knowledge Base

**What this is:** orientation and memory for the `.pi` project ecosystem.
Use it to understand what projects exist, what was built, and what decisions
were made.

**What this is NOT:** a debugging tool or code reference.
- To find a symbol → use `grep` (fastest)
- To trace callers/callees → use `codegraph`
- To debug a bug → read the source code directly
- To understand the project → you're in the right place

See the `wiki-use` skill for the full wiki/CodeGraph/grep split.

## Projects

Isolated project-level knowledge — each project gets its own folder with overview, architecture, and context.

| Project | Overview | Architecture | Status |
|---------|----------|-------------|--------|
| [pi-web](C:/Users/User/.pi/pi-web/.wiki/overview.md) | [overview](C:/Users/User/.pi/pi-web/.wiki/overview.md) | [architecture](C:/Users/User/.pi/pi-web/.wiki/architecture.md) | **Active** — 8 pages |
| [Archon](C:/Users/User/archon/.wiki/overview.md) | [overview](C:/Users/User/archon/.wiki/overview.md) | — | ⚠️ Stub — 1 page |
| [pi-mono](C:/Users/User/pi-mono/.wiki/overview.md) | [overview](C:/Users/User/pi-mono/.wiki/overview.md) | — | ⚠️ Stub — 1 page |
| [Mockly](E:/OneDrive%20-%20The%20University%20of%20Auckland/Desktop/Mockly/Mockly/.wiki/index.md) | [index](E:/OneDrive%20-%20The%20University%20of%20Auckland/Desktop/Mockly/Mockly/.wiki/index.md) | [architecture](E:/OneDrive%20-%20The%20University%20of%20Auckland/Desktop/Mockly/Mockly/.wiki/architecture.md) | **Active** — see local index |

### pi-web pages

| Page | Summary |
|------|---------|
| [overview](C:/Users/User/.pi/pi-web/.wiki/overview.md) | Project facts, directory layout, features |
| [architecture](C:/Users/User/.pi/pi-web/.wiki/architecture.md) | Component tree, data flow, store architecture, theme system |
| [components](C:/Users/User/.pi/pi-web/.wiki/components.md) | 13-component catalog with edit iteration history |
| [stores](C:/Users/User/.pi/pi-web/.wiki/stores.md) | Zustand stores: chatStore, uiStore, sessionStore |
| [build history](C:/Users/User/.pi/pi-web/.wiki/build-history.md) | Full build log: 1,235 tool calls, 61 writes, 350 edits across one session |
| [bug fixes](C:/Users/User/.pi/pi-web/.wiki/bugfixes.md) | 3 bugs fixed 2026-05-31: subagent sidebar, thinking sync, live indicator |
| [bug fixes 2026-06-08](C:/Users/User/.pi/pi-web/.wiki/bugfixes-2026-06-08.md) | Task panel (plain-text result format, regex `\s*`/`\n` bug, session-scoping, refresh-safe), AskPanel UX, (since-corrected) CLI mirror limitation |
| [bug fixes 2026-06-09](C:/Users/User/.pi/pi-web/.wiki/bugfixes-2026-06-09.md) | Ask CLI+web mirroring: JSON.stringify drops undefined (lost question id), CLI Escape race, TUI `done()` callback capture; corrects 2026-06-08's architectural conclusion |

### Mockly pages

Canonical page list lives in the project wiki itself:
[Mockly index](E:/OneDrive%20-%20The%20University%20of%20Auckland/Desktop/Mockly/Mockly/.wiki/index.md)
— 9 pages (overview, architecture, status, requirements, decisions, lessons,
test-suite, log, index). Per-page summaries are **not** duplicated here; one
browse list per wiki (see the base skill's "one canonical browse location"
rule, applied cross-wiki).

## Built (.pi meta-project)

Features and infrastructure shipped for the Pi configuration project itself.

| Page | Summary |
|------|---------|
| [pi-web — build history](built/pi-web.md) | Cross-reference to the pi-web project build |
| [subagent system](built/subagent-system.md) | Investigation of subagent patterns + agent definitions |
| [skills research](built/skills-research.md) | Pi marketplace + web skills research |
| [workflow extension](built/workflow-extension.md) | Workflow creation system with spec-plan-execute-review chain |
| [extensions](built/extensions.md) | Pi extension system and installed extensions |
| [workflows](built/workflows.md) | YAML workflow definitions |
| [mcp-server](built/mcp-server.md) | MCP server plan |
| [task-system](built/task-system.md) | Session-scoped task tracking |
| [agent-agents](built/agent-agents.md) | Subagent definitions roster |
| [skills](built/skills.md) | Installed skills catalog |
| [wiki-maintenance skill](built/skills-wiki-maintenance.md) | Custom skill for wiki ingest, update, research + self-improvement |
| [wiki graph](built/wiki-graph.md) | Interactive D3 force-directed knowledge graph visualization for pi-web |
| [wiki version control](built/wiki-version-control.md) | Git repos, daily scan, 4-day audit cycle, pre-commit gate |
| [agent orchestration architecture](built/agent-orchestration-architecture.md) | U→P→E→V system design: orchestrator, verification protocol, scout specialization |
| [user model](built/user-model.md) | Persistent user memory at ~/.pi/user/ — preferences, personality, learned patterns across sessions |
| [run-journal](built/run-journal.md) | Live diagnostic markdown the agent maintains during non-trivial tasks; shared with the user for alignment verification — verbatim request, success criteria, decomposition, hypothesis loop |

## Archive

Historical pages — preserved for reference, no longer current.

| Page | Summary |
|------|---------|
| [PKB plan (archived)](built/pkb-plan.md) | Original custom PKB design — superseded by LLM Wiki extension |

## Experiments

| Page | Summary |
|------|---------|
| [experiments index](experiments/index.md) | (pending analysis) |

## Context

| Page | Summary |
|------|---------|
| [project overview](context/overview.md) | .pi meta-project directory layout and subsystems |
| [architecture](context/architecture.md) | How pi-web, extensions, workflows, and agents fit together |
| [tools](context/tools.md) | Available tools and their configurations |
| [sessions](context/sessions.md) | Session directory layout |

## References

Operational references for wiki authors — templates, quality rules, recipes.

| Page | Summary |
|------|---------|
| [quality rules](references/quality.md) | .pi-specific quality rules (extends LLM Wiki quality.md) |
| [source template](references/source-template.md) | Template for copied verbatim sources |
| [session recipe](references/session-recipe.md) | Pi session extraction recipe (extends LLM Wiki pi-session-recipe) |
| [synthesis & archive](references/synthesis-archive.md) | Rules for synthesis and archive page types |
| [correction pattern](references/correction-pattern.md) | How to document corrections instead of silent rewrites |
| [pi ctx.ui.custom lifecycle](references/pi-ctx-ui-custom-lifecycle.md) | pi-core's lazy install of `ctx.ui.custom` — 2026-06-09 corrected: wrappable at patch-creation time because `bind(ctx.ui)` defers method lookup until invocation, after pi-core installs the real method |

## Patterns

Behavioural and debugging patterns observed across sessions.

| Page | Summary |
|------|---------|
| [symptom-chasing anti-pattern](patterns/symptom-chasing-antipattern.md) | When the agent patches symptoms instead of investigating root cause — observed 2026-06-08 and recurred 2026-06-09 pi-web debugging |
| [framework decay under iteration](patterns/framework-decay-under-iteration.md) | Why the U/P/E/V framework gets applied early in a task arc then abandoned in the long debugging tail — the failure mode the run-journal pattern is designed to defeat |

## Meta

| Page | Summary |
|------|---------|
| [SCHEMA.md](SCHEMA.md) | Per-project conventions |
