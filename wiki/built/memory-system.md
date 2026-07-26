---
title: "Memory System — Canonical Map"
type: built
updated: 2026-06-10
sources:
  - "session 2026-06-09 memory system redesign"
  - "scout report on industry skill-routing patterns"
  - "~/.pi/agent/AGENTS.md"
  - "~/.pi/agent/INDEX.md"
  - "~/.pi/agent/skills/run-journal/SKILL.md"
  - "~/.pi/agent/skills/agent-self-preservation/SKILL.md"
tags: [memory, agent-infrastructure, architecture, canonical]
---

# Memory System — Canonical Map

Single map of every memory tier the agent uses. If you can answer **"where does this fact go?"** by reading this file, the system is doing its job. If you can't, fix this file first.

## The four layers

```
EPHEMERAL                                  DURABLE
─────────                                  ───────

Layer 1: Live working memory               Layer 2: User model
  ~/.pi/runs/<slug>/journal.md               ~/.pi/user/
  ~/.pi/runs/ACTIVE.md (pointer)             ├── PROFILE.md
                                             └── memory/
                                                 ├── MEMORY.md
Lifetime: one task                               ├── corrections.md
Scope: shared with user                          ├── preferences.md
                                                 └── sessions/
                                           Lifetime: forever
                                           Scope: across all projects, about the human

                                           Layer 3: Wiki (per-project)
                                             <repo>/.wiki/
                                             ├── overview.md
                                             ├── decisions.md
                                             └── lessons.md
                                           Lifetime: forever
                                           Scope: about the project being worked on
                                           Plus pi meta-project's wiki:
                                             ~/.pi/llm-wiki/{built,references,context,log.md}

                                           Layer 4: Agent self-knowledge
                                             ~/.pi/agent/
                                             ├── AGENTS.md   (always-on, ≤120 lines)
                                             └── skills/
                                                 ├── INDEX.md (catalog)
                                                 └── <name>/SKILL.md (depth)
                                           Lifetime: forever
                                           Scope: how the agent itself should operate
```

## What each layer is for, who writes it, when it loads

| Layer | What's in it | Who writes | Always loaded? |
|---|---|---|---|
| **1 — Journal** | Current-task working memory: verbatim user request, agreed criteria, decomposition, hypothesis, per-attempt log | Agent + user (shared) | Active journal re-read before every tool call; ACTIVE.md user-readable any time |
| **2 — User model** | The human's preferences, personality, learnings, corrections, session summaries | Agent (with user approval for PROFILE) | Loaded at session start: PROFILE.md full + MEMORY.md first 200 lines + last 10–15 session summaries |
| **3 — Wiki** | The project's overview, decisions, lessons. Pi meta-project wiki holds built/, references/, context/, log.md | Agent via wiki-maintenance | Read at session start if working in a project dir (`<repo>/.wiki/` if exists, else `~/.pi/llm-wiki/`) |
| **4 — Agent self-knowledge** | AGENTS.md (always-on rules + dispatch); INDEX.md (catalog, sibling of AGENTS.md); skills/<name>/SKILL.md (depth per skill) | Mostly agent; user proposes/approves | AGENTS.md injected as `<project_instructions>` every turn (cached). Skill bodies on-demand. |

## Storage rule — the single most useful gate

**A fact gets stored only if discovering it again would require either (a) re-running a failed experiment, (b) re-reading a long history, or (c) asking the user. If `grep`, `read`, or `codegraph` would find it in under 30 seconds, don't store it.**

Examples applied:

| Fact | Discovery cost | Store? | Where |
|---|---|---|---|
| File path of websocket handler | grep, 1 second | no | — |
| User prefers TypeScript | from `package.json`, 5 seconds | no | — |
| `JSON.stringify` drops `undefined` silently | known JS but the *lesson* "always defend at boundary" is experience-only | yes | `debugging-protocol` rule E (already done) |
| Pi kills itself with bare `pkill` | requires crashing pi to discover | yes | `agent-self-preservation` skill |
| The architecture migrated hub→standalone | requires reading git history + multiple sessions | yes | `<repo>/.wiki/decisions.md` |
| User prefers frameworks over scripts | requires multiple sessions to observe | yes | user model: `preferences.md` |
| `pi-web` uses Preact | visible in package.json | no | — |
| Session of 2026-06-09 fixed three CLI+web mirror bugs | requires reading the JSONL | yes | session summary + per-repo lessons.md |

## Routing decision tree — where does this fact go?

```
Is the fact about THE HUMAN (preference, personality, standing rule)?
├─ YES → Layer 2
│         ├─ Standing rule, expected forever → PROFILE.md (user-written)
│         ├─ Learned from observation → memory/preferences.md
│         ├─ Came from a correction the user gave → memory/corrections.md
│         └─ One paragraph about this session → memory/sessions/<date>.md
│
Is the fact about A PROJECT being worked on?
├─ YES → Layer 3
│         ├─ Working in a per-repo project (pi-web, mockly, etc.) → <repo>/.wiki/
│         │   ├─ What is it / why does it exist → overview.md
│         │   ├─ Design decision with alternatives considered → decisions.md
│         │   └─ Mistake or near-miss worth preserving → lessons.md
│         └─ Working in pi meta-project → ~/.pi/llm-wiki/
│             ├─ Cross-cutting infrastructure (skills, journal, ...) → built/<name>.md
│             ├─ Operational reference (conventions, lifecycles) → references/<name>.md
│             ├─ Domain glossary, project orientation → context/<name>.md
│             └─ Anything wiki-touching → append to log.md
│
Is the fact about HOW THE AGENT ITSELF SHOULD OPERATE?
├─ YES → Layer 4
│         ├─ Must fire reliably late in a session ("never kill pi")
│         │   → AGENTS.md hard rules + depth in agent-self-preservation
│         ├─ Procedural depth for a recognized moment
│         │   → new or existing SKILL.md
│         └─ Catalog entry needed → ~/.pi/agent/INDEX.md
│
Is the fact about WHAT'S HAPPENING RIGHT NOW (this task)?
└─ YES → Layer 1 (journal Attempt entry, User notes section, or Lessons)
```

## Load order at session start

(Per AGENTS.md ritual)

1. **Always (cached prefix)**: AGENTS.md (~113 lines) — orchestration principles + hard rules + journal essentials + dispatch table.
2. **Layer 2 user model**: PROFILE.md (full) + MEMORY.md (first 200 lines) + memory/sessions/ (last 10–15).
3. **Layer 3 wiki**: if working in a repo with `<repo>/.wiki/`, read overview + decisions + lessons. If working in pi, read relevant `~/.pi/llm-wiki/built/` and `references/` for the current task type.
4. **Layer 4 skills**: read `~/.pi/agent/INDEX.md` when starting a non-trivial task (the "list skills first" hard rule).
5. **Layer 1 journal**: created at task start for non-trivial tasks; re-read before each tool call.

## Eviction policy (usage-based, not age-based alone)

Each tier has a numeric threshold + an action. Files near threshold surface as candidates for review, never auto-deleted.

| Tier / file class | Threshold | Action |
|---|---|---|
| `memory/MEMORY.md` | 200 lines | Prune lowest-utility entries (move to topic files or delete) |
| `memory/sessions/` | Older than 30 days verbatim | Compact into a monthly digest |
| `memory/corrections.md` | Rule baked into a skill or AGENTS.md hard rule AND helpful_count ≥ 5 | Retire (move to wiki forensic note if narrative is valuable) |
| `~/.pi/llm-wiki/log.md` | Older than 60 days | Archive to `log-archive-<year>.md` |
| `<repo>/.wiki/*.md` | Last access > 180 days AND access_count < 3 | Flag for review |
| `~/.pi/llm-wiki/built/`, `references/`, `context/` | Score below threshold OR `last_modified > 180 days AND access_count < 3` | Flag for review |
| `~/.pi/agent/skills/<name>/SKILL.md` | `read_count = 0` for 90 days | Flag for review or removal |
| `<repo>/.wiki/lessons.md` per-entry | Entry's rule fully encoded in a skill | Compress to one-paragraph forensic note |

### Usage tracking mechanics

Implemented via sidecar files: each tracked path has `<file>.meta.json` next to it with:

```json
{
  "access_count": 0,
  "last_accessed": null,
  "last_modified": "...",
  "helpful_count": 0,
  "ignored_count": 0
}
```

Updated by:
- The harness logging `read` operations on tracked paths
- The agent updating `helpful_count` when a task closes successfully and the file was referenced in Attempts
- The agent updating `ignored_count` when a file was read but the next action did not reflect its content

Eviction score: `log(access_count + 1) × (helpful_count + 1) / (ignored_count + 1) × recency_decay`. Periodic audit (via `wiki-audit` skill) surfaces lowest-score files as prune candidates.

## Deprecated / removed tiers

For orientation:

- **Old "core memory" at `~/.pi/agent/llm-wiki/patterns/`** — abandoned, content redundant with skills.
- **`~/.pi/llm-wiki/projects/`** — moved to per-repo `<repo>/.wiki/`. The pi meta-project wiki no longer has a `projects/` subfolder by default. Re-created only if pi-context sessions touch projects without their own wiki.
- **`~/.pi/agent/APPEND_SYSTEM.md`** — consolidated into `AGENTS.md` to eliminate duplication. Pi's loader tolerates the missing file.
- **`~/.pi/llm-wiki/patterns/`** — most pattern docs being compressed into the skills they inspired. The `patterns/` folder becomes a holding pen for unresolved observations only, not a parallel knowledge tier.

## Open issues / known gaps

1. **Sidecar usage tracking not yet implemented.** Designed above, no harness extension yet. Manual audit only until extension built.
2. **2026-06-08 session has no summary.** Back-fill pending (later step in current redesign).
3. **9 stray markdown files at `~/.pi/` root.** Triage pending (later step).
4. **`memory/projects/`** — never used. Will be removed once per-repo `.wiki/` migration is complete.
5. **`~/.pi/llm-wiki/log.md`** — at 289 lines, approaching the 60-day archive threshold. Will need first archive sweep.

## Cross-references

- `~/.pi/agent/AGENTS.md` — the always-on file
- `~/.pi/agent/INDEX.md` — skill catalog (sibling of AGENTS.md, outside skills/ so pi doesn't parse it as a skill)
- `~/.pi/agent/skills/run-journal/SKILL.md` — Layer 1 mechanics
- `~/.pi/agent/skills/agent-self-preservation/SKILL.md` — Layer 4 safety guardrails
- `~/.pi/llm-wiki/built/user-model.md` — Layer 2 deeper documentation
- `~/.pi/llm-wiki/built/run-journal.md` — Layer 1 deeper documentation
- `~/.pi/llm-wiki/references/memory-rules.md` — operational routing rules (paired with this file)
