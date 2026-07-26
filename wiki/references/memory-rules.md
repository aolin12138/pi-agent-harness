---
title: "Memory Rules — operational routing"
type: reference
updated: 2026-06-10
sources:
  - "built/memory-system.md (canonical map)"
  - "session 2026-06-09 memory system redesign"
tags: [memory, routing, eviction, operational]
---

# Memory Rules

The pocket-card version of the memory system. Read this when you need to answer **"where does this go?"** in under 10 seconds. If you need depth, read `built/memory-system.md`.

## The one rule that gates everything

**Don't store what's grep-able in 30 seconds.**

Before writing any new memory or wiki entry, ask: *if I deleted this and tried to find it again, how long would it take?* If under 30 seconds via `grep`/`read`/`codegraph` — don't store. If longer — store, somewhere appropriate per the routing below.

Things that PASS the gate (worth storing):
- A lesson from a failed experiment ("3 hours debugging because we didn't log the wire payload")
- A design decision with alternatives considered
- A user's standing preference
- An operational hazard discovered by crashing into it ("pi kills itself if you bare-kill node")

Things that FAIL the gate (don't store):
- File paths (`grep` finds them)
- Language/framework facts (in the docs)
- Code patterns visible in the repo
- One-off observations that don't change behavior

## Routing — where does X go?

| The thing | Goes to | File |
|---|---|---|
| User preference / personality / standing rule | Layer 2 | `~/.pi/user/PROFILE.md` (user-written) or `memory/preferences.md` (agent-observed) |
| Correction the user gave the agent | Layer 2 | `~/.pi/user/memory/corrections.md` |
| One-paragraph summary of a session | Layer 2 | `~/.pi/user/memory/sessions/<date>.md` |
| Index entry "this happened in this session" | Layer 2 | `~/.pi/user/memory/MEMORY.md` |
| Design decision on a per-repo project | Layer 3 (repo wiki) | `<repo>/.wiki/decisions.md` |
| Mistake / lesson on a per-repo project | Layer 3 (repo wiki) | `<repo>/.wiki/lessons.md` |
| Project description / vision / quick facts | Layer 3 (repo wiki) | `<repo>/.wiki/overview.md` |
| Cross-cutting built infrastructure (skills, journal, memory system itself) | Layer 3 (pi meta-wiki) | `~/.pi/llm-wiki/built/<name>.md` |
| Operational reference (conventions, lifecycles, pocket cards) | Layer 3 (pi meta-wiki) | `~/.pi/llm-wiki/references/<name>.md` |
| Note that a wiki change was made | Layer 3 | `~/.pi/llm-wiki/log.md` (append-only narrative) |
| Hard rule the agent must follow on every action | Layer 4 | `~/.pi/agent/AGENTS.md` §1 (hard rules) — one-liner + skill pointer |
| Depth procedure for a recognized moment | Layer 4 | `~/.pi/agent/skills/<name>/SKILL.md` |
| New skill catalog entry | Layer 4 | `~/.pi/agent/INDEX.md` (sibling of AGENTS.md) |
| Operational safety rule (kill, restart, file-loadability) | Layer 4 | `~/.pi/agent/skills/agent-self-preservation/SKILL.md` |
| What I currently believe in this task / what I just tried | Layer 1 (journal) | `~/.pi/runs/<slug>/journal.md` Attempt entry |

## Quick decisions

### "Should this be a skill or an AGENTS.md rule?"

| If… | Then… |
|---|---|
| The rule must fire reliably even 200 turns into a session | **AGENTS.md hard rule** (+ skill for depth) |
| The decision to load it requires its own content (catch-22) | **AGENTS.md essential inline** (+ skill for depth) |
| It's procedural depth needed only at a specific moment | **Skill, on-demand load** |
| It's domain-specific and rarely needed | **Skill, trust description** |

### "Should this be Layer 2 or Layer 3?"

| If the fact is about… | Then… |
|---|---|
| The human (preferences, history, standing rules) | **Layer 2 (user model)** |
| A project being built / worked on | **Layer 3 (wiki for that project)** |
| The agent's own operations | **Layer 4 (skill or AGENTS.md)** |
| This-task-right-now | **Layer 1 (journal)** |

### "Project work in pi context — pi wiki or repo wiki?"

Wiki entries for work on project X live in **X's wiki**, regardless of which cwd the session ran from. A pi-context session that fixes a pi-web bug writes the lesson into `~/.pi/pi-web/.wiki/lessons.md`, not into pi's wiki.

The pi meta-project's own wiki (`~/.pi/llm-wiki/`) is for **work on pi itself** — agent infrastructure, skills, memory system, orchestration. Not for "things the agent did while in pi cwd".

## Eviction — what to retire, when

**Numeric thresholds:**

| File class | Trigger | Action |
|---|---|---|
| `memory/MEMORY.md` | > 200 lines | Prune lowest-utility entries |
| `memory/sessions/<date>.md` | older than 30 days | Compact into monthly digest |
| `memory/corrections.md` entry | Rule baked into skill/AGENTS.md AND helpful_count ≥ 5 | Retire (move to forensic note if narrative valuable) |
| `~/.pi/llm-wiki/log.md` | older than 60 days | Archive to `log-archive-<year>.md` |
| Any wiki page | `last_modified > 180 days AND access_count < 3` | Flag for review |
| Any skill `SKILL.md` | `read_count = 0` for 90 days | Flag for review or removal |
| Per-repo `lessons.md` entry | Rule fully encoded in a skill | Compress to one-paragraph forensic note |

**Usage-based scoring** (when sidecar usage tracking is in place):

```
score = log(access_count + 1) × (helpful_count + 1) / (ignored_count + 1) × recency_decay
```

Files below threshold surface as eviction candidates in a periodic `wiki-audit` sweep. Never auto-deleted. User approves each.

## What's wrong if you can't find this rule

If you reach for a fact and don't know where it should live, this file failed at its job. Two recovery steps:

1. Open `built/memory-system.md` for the deep map.
2. If even that doesn't help, the routing has a gap — add to this file under "Routing" with the right destination, after a quick alignment check with the user.

## Cross-references

- `~/.pi/llm-wiki/built/memory-system.md` — canonical map with the full layer descriptions, deprecated tiers, usage tracking mechanics
- `~/.pi/agent/AGENTS.md` — the always-on file (Layer 4)
- `~/.pi/agent/INDEX.md` — Layer 4 skill catalog
- `~/.pi/agent/skills/run-journal/SKILL.md` — Layer 1 mechanics
