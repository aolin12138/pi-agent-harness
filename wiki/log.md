# Operations Log

## [2026-06-02] ingest | Wiki graph visualization feature

- Registered session 2026-05-31T12-32 (2.1 MB) — wiki graph + audit dashboard for pi-web
- Compiled: built/wiki-graph.md — full feature page with architecture, force model, rendering, bugs, tests
- Updated: projects/pi-web/overview.md (added wiki graph to features)
- Updated: projects/pi-web/architecture.md (added WikiGraphPanel to component tree, API endpoints, keyboard shortcut)
- Updated: projects/pi-web/build-history.md (added wiki graph session entry)
- Updated: raw-sources/index.md (registered session)
- Updated: index.md (added wiki-graph to built/; pi-web page count → 6)

Append-only log of wiki operations. Verbs from LLM Wiki protocol:
- `ingest` — register source + compile page + log + update index (full pipeline)
- `register` — source registered; compile pending
- `scaffold` — one-time wiki initialization (not an LLM Wiki verb; .pi convention)

**No `remove` or `delete`.** The LLM Wiki protocol never deletes pages — archive
them instead (`type: archive`). Content corrections use `### Correction:` pattern.
Index entries are removed as part of a normal `ingest`.

## [2026-05-31] ingest | pi-web bugfix session + core memory candidates

- Registered session 2026-05-31T10-09 in raw-sources/index.md
- Compiled: projects/pi-web/bugfixes.md — 3 bugs with root causes, fixes, and
  file references
- Updated: index.md (added bugfixes page)
- Extracted 2 behavioral pattern candidates to core memory:
  - candidates/browser-test-before-done.md — Playwright DOM verification
  - candidates/cross-system-api-debugging.md — curl + python boundary testing
  (both need ≥2 sessions to promote from candidate → approved)

## [2026-05-31] scaffold | Wiki initialized

- Created SCHEMA.md, index.md, log.md
- Created raw-sources/index.md with session registry
- Created topic directory stubs: built/, experiments/, context/, meta/
- Schema proposed with domain, source buckets, topic taxonomy, page types

## [2026-05-31] register | .pi session directory

- Registered all sessions under `--C--Users-User-.pi--` in raw-sources/index.md

## [2026-05-31] ingest | pi-web build session

- Registered session 2026-05-27 (7MB) — "build a web ui for my pi process"
- Compiled: built/pi-web.md — complete build history with 61 writes, 350 edits, component tree
- Updated: index.md

## [2026-05-31] ingest | subagent investigation session

- Registered session 2026-05-12 (5.1MB) — "investigate on subagent"
- Compiled: built/subagent-system.md — agent definitions, workflow chain
- Updated: index.md

## [2026-05-31] ingest | skills marketplace research session

- Registered session 2026-04-27 (2.7MB) — "research the skills in the pi package marketplace"
- Compiled: built/skills-research.md — marketplace research, autoresearch integration
- Updated: index.md

## [2026-05-31] ingest | workflow extension session

- Registered session 2026-04-29 (2.1MB) — "work on the workflow extensions"
- Compiled: built/workflow-extension.md — workflow creation system, spec-plan-execute-review test
- Updated: index.md

## [2026-05-31] ingest | Mockly project — full codebase exploration

- Explored Mockly repo directly (not sessions): README, package.json, directory tree, mcp_plan.md, BYOK.md
- Compiled: projects/mockly/overview.md — AI interview practice app, React 19 + Express + ElevenLabs
- Compiled: projects/mockly/architecture.md — monorepo layout, component graph, AI tooling
- Compiled: projects/mockly/status.md — 10 confirmed built, 3 planned/WIP, 4 gaps identified
- Compiled: projects/mockly/requirements.md — 14 functional + 4 non-functional requirements
- Registered repo in raw-sources/codebase/
- Updated: index.md, SCHEMA.md (added codebase bucket + project page template)
- Updated: wiki-maintenance skill (added §2 codebase exploration)

## [2026-05-31] ingest | Mockly project sessions

- Registered 2 Mockly sessions in raw-sources/index.md
- Compiled: projects/mockly/overview.md (replaced stub)
- Sessions are diagnostic/debug only — no build artifacts, no Mockly-specific work done
- Updated: index.md (Mockly status changed from stub to analyzed)

## [2026-05-31] ingest | wiki version control & audit system

- Git init both wikis (llm-wiki/ and agent/llm-wiki/)
- Created wiki-audit skill at agent/skills/wiki-audit/SKILL.md
- Created scan-unregistered-sessions.py at bin/
- Created wiki-audit.yaml and wiki-daily-scan.yaml workflows
- Initial git commits for both wikis
- Compiled: built/wiki-version-control.md, built/skills-wiki-maintenance.md (v2)
- Updated: built/skills.md, built/workflows.md, index.md

## [2026-05-31] ingest | wiki-maintenance skill (v2 — minimal)

- Created skill at `~/.pi/agent/skills/wiki-maintenance/SKILL.md` (5.1 KB)
- Reduced from 11.2 KB: removed duplication of base LLM Wiki skill
- Now only adds: Pi session Python recipe, web research for gaps, self-improvement loop
- All ingest/lint/quality gates defer to base LLM Wiki skill
- Compiled: built/skills-wiki-maintenance.md
- Updated: built/skills.md, index.md

## [2026-05-31] ingest | Project-level wikis

- Created projects/ directory for isolated project knowledge
- Moved pi-web into projects/pi-web/ with overview, architecture, components, stores, build-history
- Created stubs for archon, pi-mono, mockly
- Updated SCHEMA.md to document projects/ taxonomy
- Updated index.md with project-level navigation

## [2026-05-31] ingest | wiki-use skill + system prompt update (from parallel session)

- Created wiki-use skill: wiki-first protocol, navigation, memory retrieval, CodeGraph exploration, gap detection, storage-worthiness
- Updated APPEND_SYSTEM.md: wiki-first directive at top of system prompt
- wiki-maintenance frontmatter: points to wiki-use for consumption patterns
- Clean separation: wiki-use (read), wiki-maintenance (write), wiki-audit (check)
- Updated: built/skills.md

## [2026-05-31] ingest | wiki-maintenance — core memory extraction

- Updated §1: session extraction now includes behavioral pattern extraction
  as step 6 (was 5 steps, project-only)
- Added §1.1: Behavioral pattern extraction with signal table, pattern
  template, and ≥2-session promotion rule
- Core memory patterns: success/ (repeated tool sequences), failure/
  (retries, dead-ends), latent/ (unusual choices, context drift)
- Every session ingest now feeds BOTH project wiki AND core memory

## [2026-05-31] ingest | references/ folder — LLM Wiki integration

- Created `references/` directory with 5 pages adapting LLM Wiki package features:
  - `quality.md` — .pi-specific quality rules (extends LLM Wiki quality.md)
  - `source-template.md` — template for copied verbatim sources
  - `session-recipe.md` — Pi session extraction (extends LLM Wiki pi-session-recipe)
  - `synthesis-archive.md` — rules for synthesis and archive page types
  - `correction-pattern.md` — how to document corrections
- Updated SCHEMA.md: noted derivation from LLM Wiki template; added `bugfix` and
  `archive` page types with cascade-update rules
- Updated wiki-audit skill: inline depth minimums, done checklist, references/
- Updated wiki-maintenance skill: points to local references/session-recipe.md
- Updated index.md: added References section
- Each reference explicitly links to LLM Wiki canonical for full detail

## [2026-05-31] ingest | pi-web sidebar subagents + thinking sync + live indicator

- Registered session 2026-05-31T10-09 (pi-web bugfix session)
- Diagnosed and fixed 3 bugs in pi-web frontend + backend:
  - Subagent sessions not showing: `/api/sessions` now returns `parentSession`;
    `isSubagentSession()` uses `!!session.parentSession`; path separators normalized
  - Thinking level CLI→web sync: extension server broadcasts `thinking_level_changed`;
    rpc-handler updates `uiStore` on change
  - Live indicator broken: `isLive()` now normalizes path separators before comparison
- Added Live section to sidebar with green pulsating indicator
- Fixed Vite dev server proxy: port 3001→3099 so dev and prod match
- Cleaned dead code: removed test helpers, debug logs, unused CSS
- Updated: extensions/server.ts, SessionSidebar.tsx, sessionStore.ts,
  rpc-handler.ts, websocket.ts, App.tsx, MessageList.tsx, global.css, vite.config.ts

## [2026-05-31] ingest | Wiki health audit + purpose statement

- Audited all 32 wiki pages: link integrity, frontmatter compliance, duplicates
- Fixed: removed duplicate Archive entries (skills-wiki-maintenance, wiki-version-control)
- Fixed: git-added 4 untracked files referenced in index.md
- Added: purpose statement to index.md and SCHEMA.md — wiki = orientation/memory,
  CodeGraph = structure, grep = lookup, source = debugging
- Updated: wiki-use skill restructured §2 with honest tool split table;
  CodeGraph promoted to first-class; grep acknowledged as faster for symbol lookup;
  "when to skip wiki" section added
- Marked stub projects with ⚠️
- Compiled: index.md, SCHEMA.md, wiki-use/SKILL.md

## [2026-05-31] ingest | CodeGraph adopted + PKB extension deleted

- Ran codegraph on all 3 projects: .pi (1,485 nodes, 3,872 edges), pi-web (262, 537), Mockly (746, 1,261)
- Updated wiki-maintenance skill §2: codegraph replaces manual find/read for codebase exploration
- Updated SCHEMA.md: codegraph/ source bucket replaces codebase/
- Deleted disabled PKB extension (pkb-wiki.ts, 25KB) — LLM Wiki extension is the knowledge system
- Updated built/extensions.md: added codegraph-discovered extensions (agent-manager, workflow-orchestrator, adaptive-thinking, snake)
- Updated built/pkb-plan.md: documents LLM Wiki extension as current system
- Updated raw-sources/index.md: codegraph snapshots registered for all 3 projects

## [2026-06-08] ingest | pi-web debugging session + symptom-chasing anti-pattern

- Added `projects/pi-web/bugfixes-2026-06-08.md` — six concrete bugs:
  plain-text task results, regex `\s*` matching `\n`, session-scoped
  tasks Map, full-rebuild broadcast, refresh-safe ask panel,
  AskPanel UX (Submit/Elaborate/custom-text/descriptions)
- Added `references/pi-ctx-ui-custom-lifecycle.md` — documents pi-core
  lazily installing `ctx.ui.custom` AFTER `session_start`, blocking any
  attempt to wrap the default TUI implementation (CLI+web mirror not
  possible from pure-extension code today)
- Added `patterns/symptom-chasing-antipattern.md` — behavioural analysis
  of why the session took so long: assumption-driven coding,
  patch-don't-investigate, trial-via-/reload, ignoring counter-evidence;
  turning point was user demanding a systematic trace
- Updated `~/.pi/user/memory/sessions/2026-06-07.md` with 2026-06-08
  session summary (concatenated, file has both dates)

## [2026-06-09] ingest | pi-web ask flow CLI+web mirroring + meta-failure pattern

- Added `projects/pi-web/bugfixes-2026-06-09.md` — three root causes
  fixed: (1) `JSON.stringify` drops `undefined` so question.id
  vanished on the wire → `formatResultLines` returned empty → fallback
  string; (2) shared `pendingCustomResolve` was nulled by CLI Escape
  racing the web answer; (3) TUI `done()` was never called from the
  web path so the CLI panel stayed open. Also corrects the 2026-06-08
  "architectural limitation" verdict — `ctx.ui.custom` IS wrappable,
  the previous patch just ran at the wrong time.
- Added `patterns/skill-availability-vs-loading.md` — meta-pattern:
  the symptom-chasing antipattern was already documented in the wiki
  but the agent recommitted it on the same project. Skills listed in
  `available_skills` are not skills loaded into context. Advisor
  subagent was never spawned despite hitting every trigger.
  Concrete proposals: auto-load skill on task-type detection, promote
  inline-skill-content for high-leverage skills, counter on
  recognize-these-moments cues, pattern files auto-load per project.
- Extended `patterns/symptom-chasing-antipattern.md` with 2026-06-09
  recurrence section and rule **E. The wire log is cheap. Take it
  early.**
- Updated `projects/pi-web/overview.md` See-also section with both
  2026-06-08 and 2026-06-09 bugfix pages.
- Added `~/.pi/user/memory/sessions/2026-06-09.md` (one-paragraph
  summary + meta-failure paragraph + open items).
- Updated `~/.pi/user/memory/MEMORY.md` index with 2026-06-08/09
  entries.
- Added three CORRECTION-DRIVEN entries to
  `~/.pi/user/memory/corrections.md`: wire-log-first, skill-listed-vs-loaded,
  advisor-threshold-lower.

## [2026-06-09] correction | meta-analysis from memory was wrong

- User pushed back on the meta-analysis claims published earlier today:
  patterns/ was framed as possibly an abandoned system, skills were
  claimed unloaded, advisor claimed never spawned. **All three were
  wrong.** AGENTS.md line 23 references `patterns/symptom-chasing-antipattern.md`
  as a session-startup load — patterns are alive. The compaction
  summary `<read-files>` block lists `debugging-protocol`,
  `karpathy-guidelines`, and `orchestrator-guidance` SKILL.md as read.
  Session JSONLs show 1 planner, 2 executors, 2 reviewers, 1 advisor,
  and a scout report were all spawned on the same arc.
- Renamed `patterns/skill-availability-vs-loading.md` →
  `patterns/framework-decay-under-iteration.md` and rewrote the
  content. New pattern: the framework was applied correctly in the
  architectural phase, then decayed in the long debugging tail when
  new symptom classes emerged that the original advisor never saw.
  The failure was not spawning a SECOND advisor for new sub-symptoms.
- Added two new corrections-driven memory entries: "framework decays
  under iteration pressure (not 'not loaded')" and "do not write
  session meta-analysis without checking session evidence". The
  latter mirrors the existing wiki rule about grepping a real input
  before writing a parser.
- Updated cross-references in `projects/pi-web/bugfixes-2026-06-09.md`
  and `patterns/symptom-chasing-antipattern.md` to point at the
  renamed pattern.

## [2026-06-09] ingest | run-journal pattern + framework redesign

- Built `~/.pi/agent/skills/run-journal/SKILL.md` + `JOURNAL-TEMPLATE.md`
  + `~/.pi/runs/ACTIVE.md` (always-current pointer file). Live diagnostic
  markdown the agent maintains during non-trivial tasks; per-section
  sourcing rules tie each section to one engineering skill
  (verification-protocol for criteria, karpathy-guidelines for
  decomposition, debugging-protocol for hypothesis). Failure triggers
  enumerated: 3 FAIL Attempts → halt + advisor; 2 user contradictions
  → halt + re-confirm alignment; adding fallback/cache/timeout →
  workaround logged as debt.
- Design principle the user added mid-discussion: **journal is for both
  agent and user**, not an internal diary. Status header table at top,
  plain-language summary alongside structured fields, User notes
  section, user-edits-allowed, agent re-reads before every tool call.
- Documented in `built/run-journal.md`. Cross-referenced from
  `index.md` (Built table + Patterns table both updated). Patterns
  table now also lists `framework-decay-under-iteration.md`.
- Corrected `references/pi-ctx-ui-custom-lifecycle.md` row in index:
  `ctx.ui.custom` IS wrappable when captured at patch-creation time
  because `bind(ctx.ui)` defers the method lookup. 2026-06-08's
  "architectural limitation" framing was wrong; 2026-06-09 corrects it.
- AGENTS.md §3 added: "Before any non-trivial task — load
  run-journal/SKILL.md and start a journal." Section 4 renumbered for
  bug-specific guidance. Whenever the agent cannot state its current
  hypothesis in one sentence, it re-reads the active journal.
- Added `~/.pi/llm-wiki/projects/pi-web/runs/` directory ready for
  archived journals.
- Rewrote `~/.pi/user/memory/sessions/2026-06-09.md` to cover the full
  arc (technical fixes → wrong meta-analysis → user correction →
  framework decay pattern → run-journal infrastructure), not just the
  technical fixes from Part A.

## [2026-06-13] relocate | Per-project wikis moved to repo-local `.wiki/`

- Moved `projects/pi-web/` (8 files + runs/) → `C:/Users/User/.pi/pi-web/.wiki/` ✓
- Moved `projects/mockly/` (4 files) → `E:/OneDrive - The University of Auckland/Desktop/Mockly/Mockly/.wiki/` ✓
- Moved `projects/archon/` (1 file) → `C:/Users/User/archon/.wiki/` ✓
- Moved `projects/pi-mono/` (1 file) → `C:/Users/User/pi-mono/.wiki/` ✓
- Deleted empty `~/.pi/llm-wiki/projects/` directory ✓
- Updated cross-references: index.md (project tables + page lists), built/wiki-graph.md (See also), references/pi-ctx-ui-custom-lifecycle.md, raw-sources/failure-analysis-2026-06-08.md, built/run-journal.md
- Added `<repo>/.wiki/` to run-journal.md archive path; removed stale reference to deleted `patterns/symptom-chasing-antipattern.md`
- No unresolved issues — all destination repos had write access, no .wiki/ conflicts

## [2026-06-13] redesign | Memory system + agent self-knowledge layer

- New canonical map at `built/memory-system.md` and routing pocket-card at
  `references/memory-rules.md`. Four tiers: Journal (ephemeral), User model
  (~/.pi/user/), Wiki (per-repo), Agent self-knowledge (~/.pi/agent/).
- Storage rule formalised: "if it's grep-able in 30 seconds, don't store."
- Eviction policy: usage-based (sidecar `.meta.json` tracks access_count,
  helpful_count, ignored_count) — not age-based alone.
- Subagent strategy rewritten on the context-independence principle:
  spawn when work can be done from a self-contained brief and only the
  result needs to flow back. Validated by the wiki-relocation executor.
- AGENTS.md consolidated to 113 lines; APPEND_SYSTEM.md retired.
- New skill `agent-self-preservation` for kill rules + pre-restart
  dry-load + recovery. Hard-rule pointer in AGENTS.md §1.
- INDEX.md (skill catalog) moved out of `skills/` to sibling of AGENTS.md
  after pi loader warning surfaced the structural mistake.
- `patterns/` folder removed — behavioural lessons live in skills or
  AGENTS.md, not as descriptive parallel docs.
- SCHEMA.md updated for lean per-project pages (overview/decisions/lessons).
- All 4 per-project wikis moved to `<repo>/.wiki/` (executor subagent).
- 2026-06-08 session back-filled from JSONL. 9 stray root markdown
  files triaged.
- Forensic record archived to `runs/2026-06-09-memory-system-audit.md`.
