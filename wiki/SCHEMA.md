# Wiki Schema

Per-project conventions for the `.pi` project knowledge base. LLM proposes changes; user approves.

## Purpose

This wiki is the **orientation and memory layer** for agents working in the Pi
environment. It answers "what is this?" and "what did we decide?" — not
"where is the bug?" or "how does this function work?"

| Question | Tool |
|----------|------|
| What projects exist? | **Wiki** (index.md → projects/) |
| What was built and why? | **Wiki** (built/, decisions.md) |
| Where is function X? | **grep** — `grep -rn "symbol" src/` |
| Who calls function X? | **CodeGraph** — `codegraph callers <symbol>` |
| Is there a bug in this logic? | **Source code** — read the file directly |

See the `wiki-use` skill for the full protocol.

## Domain

Derived from the LLM Wiki `SCHEMA.template.md`. Customized for the `.pi` project.

This wiki is a **project dossier** for every project developed in the Pi environment — not just a session log. It distills knowledge from four input kinds into a single truthful picture of each project.

**In scope:** Project goals, requirements, architecture, current status, key decisions, build history, experiments, and behavioral patterns.
**Out of scope:** Raw source code (reference it, don't store it). Line-level debugging information. Individual coding tasks done via Pi for external projects (those belong in their own project wikis at the project root).

## Source buckets

Four kinds of sources feed the wiki. Each has different reliability characteristics.

| Bucket | What it contains | Reliability |
|--------|-----------------|-------------|
| `codegraph/` | CodeGraph knowledge graph snapshots — exhaustive structural map per project | `high` — AST-parsed, deterministic |
| `sessions/` | Pi agent session JSONL files (referenced, not copied) | `mixed` — LLM-generated |
| `docs/` | PRDs, design docs, requirements from the project itself | `high` — if human-authored |
| `external/` | Web research, papers, third-party docs | `unverified` until cross-referenced |

## Topic taxonomy

- `projects/<name>/` — Complete project dossier: overview, requirements, architecture, status, decisions, build history
- `built/` — Features and infrastructure implemented for the .pi meta-project itself
- `experiments/` — Approaches tested but not adopted, with rationale
- `context/` — Cross-cutting project overview, architecture, conventions, tooling
- `meta/` — Wiki self-documentation

## Project page template

As of 2026-06-10, per-project wikis live at `<repo>/.wiki/` (each repo owns its own). The pi meta-project's wiki at `~/.pi/llm-wiki/` no longer holds `projects/` by default — see `built/memory-system.md`.

The **minimum set** every project wiki should have:

| Page | Type | Content | Required? |
|------|------|---------|-----------|
| `overview.md` | `concept` | What it is, why it exists, tech stack, one-paragraph summary | **required** |
| `decisions.md` | `decision` | Key design decisions with alternatives considered and rationale | **required** |
| `lessons.md` | `reference` | Mistakes, near-misses, and operational gotchas worth preserving for future sessions | **required** |
| `architecture.md` | `concept` | File tree, component graph, dependencies | optional (only if architecture is non-obvious) |

**Removed from required set** (2026-06-10 redesign): `requirements.md`, `status.md`, `build-history.md`, `experiments.md`. These are created on demand when a project genuinely needs them, not as default scaffolding. The reason: every required page that's left empty becomes noise; the leaner default avoids stub pollution.

### Per-page conventions

- `overview.md` opens with a one-paragraph elevator pitch the user could read in 10 seconds.
- `decisions.md` is a chronological log; each entry has date, context, decision, alternatives considered, rationale.
- `lessons.md` is a chronological log; each entry has date, what went wrong, root cause, what to do differently. If the lesson generalises beyond this project, it gets promoted to a skill or AGENTS.md hard rule (see `wiki-maintenance` skill's session-to-skill extraction step).
- A pattern that doesn't yet have a clear behavioural rule lives nowhere durable — it stays in the current journal's Lessons section until the rule crystallises. Standalone `patterns/` files are not part of the default wiki structure.

## Page types

- `concept` — A system, feature, project overview, or architectural component
- `decision` — A design decision with alternatives considered
- `bug` / `bugfix` — A known issue with before/after and impact
- `open-question` — Unresolved investigation
- `source` — Raw source metadata
- `reference` — Lookup table, command list, requirements list
- `synthesis` — Connection across ≥2 wiki pages with a new conclusion. Cascade-updates as cited pages change.
- `archive` — Point-in-time snapshot of a query answer. Frozen — never cascade-updated.
- `stub` — Placeholder for pending compilation

## Lint rules

- Stale-claim threshold: 30 days (claim hasn't been re-verified)
- Relative path verification: every `](*.md)` link must resolve
- Bidirectional links: if A links to B, B must link back
- Source reliability: annotate which bucket each claim comes from
- Code snippets: reference file paths, don't embed large code blocks

## Eviction thresholds

Applied periodically via `wiki-audit` skill. Files are flagged for review, never auto-deleted.

| File class | Threshold | Action |
|---|---|---|
| `~/.pi/llm-wiki/log.md` | older than 60 days | Archive to `log-archive-<year>.md` |
| Any wiki page | `last_modified > 180 days AND access_count < 3` | Flag for review |
| `<repo>/.wiki/lessons.md` entry | Rule fully encoded in a skill | Compress to one-paragraph forensic note |

For the full eviction policy across all memory tiers, see `built/memory-system.md` and `references/memory-rules.md`.

## Notes

- The wiki stores knowledge ABOUT the project, not the project's source code
- Four-source model: sessions tell what happened; codebase tells what exists; docs tell what's intended; external fills gaps
- Projects with no sessions still get wiki pages derived from reading the repo
- `built/` vs `experiments/` tracks what shipped vs what was tested for the meta-project
