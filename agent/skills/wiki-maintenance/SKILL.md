---
name: wiki-maintenance
description: |
  Operational companion to the LLM Wiki skill. Adds: Pi session extraction
  recipes, codebase exploration for project dossiers, web research for
  gap-filling, and a self-improvement loop from core memory. Trigger on
  "update wiki", "ingest to wiki", "audit wiki", "wiki health", "fill
  wiki gaps", "research for wiki", "document project", or any explicit
  wiki maintenance request.
  
  For consuming the wiki (reading, navigating, memory retrieval), prefer
  the `wiki-use` skill which covers the wiki-first protocol and codebase
  exploration patterns.
---

# Wiki Maintenance

Thin operational layer on top of the LLM Wiki skill (`@micuintus/llm-wiki`).
The LLM Wiki skill defines the canonical ingest flow, page types, lint
rules, and quality heuristics — **always defer to it** for those. This
skill adds only what the base skill doesn't cover.

## When to use this skill vs the base skill

| Situation | Use |
|-----------|-----|
| Ingest a source (register → compile → log) | Base skill (LLM Wiki SKILL.md) |
| Page types, frontmatter, depth rules | Base skill + `references/quality.md` |
| Lint / audit wiki health | Base skill — Lint section |
| Quality gate checklist | `references/quality.md` — Done checklist |
| **Extract content from a Pi session JSONL** | **This skill — §1** |
| **Explore a codebase and compile project pages** | **This skill — §2** |
| **Find complementary sources online for wiki gaps** | **This skill — §3** |
| **Self-improvement: feed patterns back into skills** | **This skill — §4** |

## 1. Pi session extraction

The base skill's pi-session-recipe uses `jq` with event shapes
(`tool_execution_end`, `custom` with `.data.toolName`) that don't match
the current Pi JSONL format. Use this Python recipe instead.

### Current Pi JSONL format

Tool calls are stored inline in assistant message content blocks:

```python
import json, os
from collections import Counter

with open(session_path, 'r', encoding='utf-8') as f:
    for line in f:
        obj = json.loads(line)
        if obj.get('type') == 'message':
            role = obj['message']['role']
            content = obj['message']['content']  # always a list
            if role == 'user':
                text = ' '.join(c.get('text','') for c in content
                                if isinstance(c,dict) and c.get('type')=='text')
                # → first user message = session topic
            elif role == 'assistant':
                for c in content:
                    if c.get('type') == 'toolCall':
                        name = c['name']        # e.g. 'write', 'edit', 'bash'
                        args = c.get('arguments',{})
                        if name == 'write':
                            args.get('path')     # → artifact produced
                        if name == 'subagent':
                            args.get('agent')    # → which agent spawned
```

### What to extract

For each session, extract **6 things**:
1. **Topic** — first user message (first 120 chars)
2. **Tool counts** — `Counter` of tool names
3. **Artifacts** — unique paths from `write` calls
4. **Subagents** — agent names from `subagent` calls
5. **Forks** — check `parentId` field on messages for branches
6. **User signals** — preferences expressed, corrections given, decisions made

Do not copy the session file. Reference it by path in
`raw-sources/sessions/` bucket. Mark reliability `mixed` (default for
LLM-generated sessions).

### 1.1 User model extraction

After each session, check for signals worth storing in the user model
at `~/.pi/user/memory/`. This is what the agent learns about THIS user —
not generic patterns.

**What to extract:**

| Signal | Store as | Example |
|--------|----------|---------|
| User corrects same thing ≥2 times | `corrections.md` | "User corrected me twice on TypeScript null checks — always use strict null checks" |
| Preference expressed | `preferences.md` | "Prefers functional style over classes" |
| Significant project decision | project `MEMORY.md` | "Chose SQLite over Postgres for offline-first — see session X" |
| New standing instruction | PROFILE.md (propose) | Propose adding to user's PROFILE.md, wait for confirmation |
| Workflow pattern that worked | `workflows.md` | "Plan→execute→review via subagents resolved task in 1 iteration" |

**Rules:**
- Only extract when observed in ≥2 sessions (or user explicitly confirms)
- Mark confidence: explicit (user said it) > correction-driven (user corrected twice) > implied (observed 3+ times)
- Never extract sensitive data without explicit user confirmation
- Propose PROFILE.md additions — don't modify the user's profile without asking

### 1.2 Updating MEMORY.md index

After adding topic files, update `~/.pi/user/memory/MEMORY.md`:
- Add entry: `## [Date] — [Topic] (see: memory/[file].md)`
- Keep under 200 lines — remove oldest entries if over limit
- Entries are one-line summaries, not full content

### 1.3 Session summary generation

After every significant session, generate a one-paragraph summary and store
it at `~/.pi/user/memory/sessions/YYYY-MM-DD.md`. This provides lightweight
cross-session awareness without loading full transcripts.

**Format:** (see `~/.pi/user/memory/sessions/SESSION-SUMMARY-FORMAT.md`)

```markdown
## YYYY-MM-DD — <one-line topic>

<One paragraph, max 5 sentences: what was accomplished, key decisions,
patterns, open items, project context.>
```

**What to include:**
- What was accomplished (outcome, not process)
- Key decisions and rationale
- Open items or deferred work
- User preferences expressed or corrections given
- Which project(s) were worked on

**Quality test:** "If I started a new session tomorrow on this project,
would reading this summary save me from re-discovering something?"
If no, too vague. If yes but 3+ paragraphs, too long.

**Multiple sessions per day:** If the user runs multiple sessions in one
day, append to the same file with `## Session 2 — <topic>` headers.
One file per day, not one per session.

## 2. Codebase exploration (via CodeGraph)

**Default tool for exploring any project repo.** CodeGraph (`npx @colbymchenry/codegraph`)
parses the codebase into an AST-based knowledge graph — exhaustive, fast,
and queryable. Use it instead of manual `find`/`read` for discovery.

### 2.1 Initialize and index

```bash
cd <project-root>
npx @colbymchenry/codegraph init --index
```

This creates a `.codegraph/` directory and indexes every source file.
Re-run `codegraph sync` to update after code changes, or use
`codegraph watch` for auto-updates during development.

### 2.2 What to query

| Command | What it reveals |
|---------|----------------|
| `codegraph status` | Node/edge counts, languages, file breakdown |
| `codegraph files` | Full project tree with symbol counts per file |
| `codegraph query "<term>"` | Find symbols matching a term (functions, classes, interfaces) |
| `codegraph callers <symbol>` | Who calls this function/method |
| `codegraph callees <symbol>` | What this function/method calls |
| `codegraph context "<task>"` | Build markdown context for a specific task |

### 2.3 Store the snapshot

After indexing, copy the status output into `raw-sources/codegraph/<project>-<date>.md`.
This captures the structural state at a point in time for wiki compilation.

### 2.4 What to compile (same as before)

Register the repo path + codegraph snapshot in `raw-sources/codegraph/`. Then compile:

| Page | Type | Content | Derived from |
|------|------|---------|-------------|
| `overview.md` | `concept` | Goal, tech stack, one-paragraph summary | README + package.json |
| `architecture.md` | `concept` | Directory tree, component graph, dependencies, entry points | `codegraph files` + `codegraph query` |
| `status.md` | `concept` | What exists, what's WIP, what's missing | Codegraph vs README claims |

## 3. Web research for wiki gaps

Use when the wiki has missing coverage that online sources could fill.

### 3.1 Identify gaps

- Scan `index.md` for topics mentioned in See Also but lacking pages
- Check `SCHEMA.md` for declared buckets/topics that are empty
- Flag stubs older than 30 days
- **Ask the user** which gaps to prioritize

### 3.2 Search and evaluate

For each gap, run 2–4 queries with varied angles via `web_search`.
Prefer official docs, GitHub repos, peer-reviewed sources. Skip SEO
spam and unverified social media.

For each candidate: check recency (<12 months), check authority,
`fetch_content` to extract, mark `unverified` until cross-referenced.
**Propose candidates to the user** before ingesting — never auto-ingest
web content.

### 3.3 Ingest approved sources

Follow the base skill's ingest flow (register → compile → log).

## 4. Session-to-skill extraction (final ingest pass)

This is the agent-improvement pass: after the project-page and user-model
updates are done, run one more scan asking *"is there anything in this
session that future sessions need encoded as a behavioural rule, not
just as a wiki memory?"*

Aggressive surfacing, conservative committing — surface every plausible
candidate, let the user approve, edit, or reject each one. The cost of
surfacing a bad candidate is one rejection. The cost of missing a good
signal is recommitting the same failure mode in a future session.

### What to scan for

1. **Recurring procedural rule the agent should follow.**
   Example: "after 3 edits to the same surface without progress, halt
   and brief an advisor". Lives in: AGENTS.md §1 hard rules (with
   skill pointer for depth).

2. **Operational hazard the agent didn't know about.**
   Example: "pi runs as a node process; bare `pkill node` kills pi
   itself". Lives in: `agent-self-preservation` skill (deep
   procedure) + AGENTS.md §1 (the one-liner trigger).

3. **Discovery technique invented mid-session worth reusing.**
   Example: "log the literal JSON payload at boundary before
   hypothesising about shape mismatches". Lives in: AGENTS.md §1
   hard rule + `debugging-protocol` skill (depth).

4. **Decay or routing failure that suggests a rule/skill boundary
   needs adjusting.**
   Example: "on-demand skills loaded early in session decayed by the
   time they were needed". Lives in: a change to which skills are
   always-on vs on-demand, documented in `~/.pi/agent/INDEX.md`.

### How to surface each candidate

For each candidate the agent finds, present it to the user as:

```
Candidate: <one-line description>
Evidence (from this session):
  - <specific quote / file / attempt that surfaced it>
Proposed home: <AGENTS.md §1 hard rule | agent-self-preservation |
                debugging-protocol | new skill | INDEX.md change>
Proposed text: <draft of the rule or skill content>
Approve / Edit / Reject?
```

The user decides per candidate. Approved candidates are then
implemented as direct file edits.

### What this is not

This is **not** about creating new wiki patterns. Per the memory
system design (see `built/memory-system.md`), behavioural lessons
become skills or AGENTS.md rules, not standalone pattern docs. If a
lesson genuinely doesn't fit anywhere yet, it stays in the current
journal's Lessons section until the right form crystallises.

## 5. Other self-improvement signals

Beyond the session-to-skill pass, also check during maintenance:

- **User model** at `~/.pi/user/memory/` for new preferences,
  corrections, or learned facts — add to appropriate file.
- **Workflow files** — if a multi-step pattern repeated ≥3 times in
  the session, formalise as `.yaml` workflow.
- **Eviction sweep** — run usage-based eviction check from
  `references/memory-rules.md`; surface low-utility candidates for
  prune.

```
session evidence → candidate identification → user approval →
AGENTS.md / skill / INDEX update → next session benefits
```

## See also

- LLM Wiki SKILL.md (`@micuintus/llm-wiki/llm-wiki/SKILL.md`) — canonical reference
- `references/quality.md` — depth rules, reliability, correction pattern
- `~/.pi/llm-wiki/references/session-recipe.md` — .pi session extraction (extends LLM Wiki recipe)
- User model: `~/.pi/user/` — user preferences, memory, session summaries
