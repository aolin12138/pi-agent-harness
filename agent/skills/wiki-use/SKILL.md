---
name: wiki-use
description: |
  Teaches the agent to use the local project wiki (`~/.pi/llm-wiki/`) as its primary
  knowledge base before any external research. Covers: wiki-first navigation protocol,
  memory retrieval from past sessions/decisions, codebase exploration via CodeGraph,
  gap detection, and post-research gap-filling with storage-worthiness criteria.
  Trigger on any research, investigation, architecture, or "how does X work" question
  about this project — as well as explicit wiki, knowledge base, memory, or codebase
  exploration requests.
---

# Wiki-Use: Local Knowledge Base Protocol

The project wiki at `~/.pi/llm-wiki/` is the **local source of truth** for this
Pi configuration project. Before any external research, check the wiki first.

**For the wiki ingest protocol** (register → compile → log), read the
`llm-wiki` skill (`@micuintus/llm-wiki/llm-wiki/SKILL.md`) — it is the
authoritative source for how to add, update, and maintain wiki content.

## §1 Wiki-first protocol

For any question involving project architecture, agent orchestration, tooling,
past decisions, codebase structure, or build history:

1. **Entry point** — read `~/.pi/llm-wiki/index.md` to find relevant pages
2. **Drill down** — follow links to category and topic pages
3. **Cite the wiki** — when wiki content answers the question, cite the page path
4. **Only then go external** — web_search / fetch_content only if the wiki has
   no coverage, is explicitly stale (check `updated` frontmatter), or the user
   asks for new external information

If the wiki has partial coverage, use what it has and supplement with external
research — but always note which claims came from the wiki vs web.

### 1.1 When to skip the wiki

The wiki is for **orientation and memory** — understanding what a project is,
what was built, and what decisions were made. It is NOT for debugging.

**Skip the wiki and go directly to source code when:**
- Debugging a specific bug, regression, or broken feature
- Tracing data flow through multiple systems (frontend → backend → filesystem)
- Investigating runtime behavior (API responses, WebSocket messages, path formats)
- The codebase is under ~50 files — reading source is faster than navigating wiki
- The task requires precise line-level knowledge (regex patterns, comparison logic)

The wiki tells you *that* a sidebar exists. It doesn't tell you *how* the
subagent detection regex works or *why* path separators don't match.

When skipping the wiki for code exploration, use **CodeGraph** (§2) instead
of raw `grep` — it gives you call-graph traversal and symbol-level precision.

## §2 Wiki vs CodeGraph — the split

The wiki and CodeGraph serve different purposes. Use the right tool:

| Question type | Tool | Why |
|--------------|------|-----|
| "What is this project?" | **Wiki** | High-level overview, directory layout, tech stack |
| "What did we build and why?" | **Wiki** | Past decisions, build history, architectural rationale |
| "What's the current status?" | **Wiki** | Status pages, known gaps, work in progress |
| "Where is function X defined?" | **grep** | Fastest — `grep -rn "functionName" src/` |
| "Who calls this function?" | **CodeGraph** | Call-graph traversal (callers/callees) |
| "How does data flow from A → B?" | **Wiki + grep + CodeGraph** | Wiki for architecture, grep to find entry points, CodeGraph to trace callers |
| "Is there a bug in this logic?" | **Source directly** | Neither wiki nor CodeGraph — read the actual code |
| "Why does this API return X?" | **Source directly** | Runtime behavior isn't in structural tools |

**Default rule:**
- **grep** for simple symbol lookup — faster, single command, no sync needed
- **CodeGraph** for call-graph traversal — who calls this, what does this connect to
- **Wiki** for project context, history, rationale — what is this, why was it built

### 2.1 CodeGraph — first-class code exploration

CodeGraph (`npx @colbymchenry/codegraph`) provides AST-level codebase snapshots
with call-graph traversal. Use it when you need **structural context** — not
for simple symbol lookup where `grep` is faster.

**Before exploring, sync:**

```bash
cd <project-root>
npx @colbymchenry/codegraph sync   # incremental update — fast
```

If no `.codegraph/` directory exists, initialize first:

```bash
npx @colbymchenry/codegraph init --index
```

**Query patterns:**

| Task | Use | Command |
|------|-----|---------|
| Find a symbol by name | `grep` (faster) | `grep -rn "symbol" src/` |
| Find a symbol with type info | CodeGraph | `codegraph query "<term>"` |
| Who calls function X | CodeGraph | `codegraph callers <symbol>` |
| What X calls | CodeGraph | `codegraph callees <symbol>` |
| Project overview | CodeGraph | `codegraph status` |
| Full file tree | CodeGraph | `codegraph files` |

**Limitations — CodeGraph won't help with:**
- Cross-repo code (indexes one project root at a time)
- State management internals (Zustand `create()`, Redux slices — fields inside
  factories aren't top-level symbols)
- Runtime behavior (API responses, WebSocket messages, path formats)
- Config files (vite.config.ts proxies, env vars, JSON configs)

When you hit these limits, fall back to `grep` + `read`.

### 2.2 Wiki navigation

The wiki uses a browse index for discovery:

```
index.md          → browse entry: projects, built, experiments, context, meta
projects/<name>/  → project dossiers (overview, architecture, status, decisions)
built/            → features shipped for the .pi meta-project itself
context/          → cross-cutting: overview, architecture, tools, sessions
meta/             → SCHEMA.md (conventions), wiki self-documentation
```

**Categories of knowledge:**
- **Project facts** → `projects/<name>/overview.md`, `projects/<name>/architecture.md`
- **Past decisions** → `projects/<name>/decisions.md`
- **Current status** → `projects/<name>/status.md`
- **What was built** → `built/` pages
- **How things connect** → `context/architecture.md`

**Quick discovery:** `ls ~/.pi/llm-wiki/built/` lists all built-feature pages.
`ls ~/.pi/llm-wiki/projects/` lists all project dossiers.

### 2.3 Storing CodeGraph snapshots in the wiki

After exploration, capture state for wiki reference:

```bash
npx @colbymchenry/codegraph status > raw-sources/codegraph/<project>-<date>.md
```

This creates a verifiable reference point. Use the snapshot path when citing
codebase structure in wiki pages. Wiki pages SHOULD link to their CodeGraph
snapshot where applicable.

## §3 Memory retrieval

The wiki stores project knowledge. User-specific memory lives separately
at `~/.pi/user/` (see `orchestrator-guidance` skill for the user model).

| Memory type | Location | What it contains |
|-------------|----------|-----------------|
| **Project memory** | `~/.pi/llm-wiki/` | Project facts, architecture, decisions, build history |
| **User model** | `~/.pi/user/` | User preferences, personality, past decisions, learned patterns |

**When to check each:**
- "How is X built?" → project memory (built/, projects/)
- "What did we decide about Y?" → project memory (decisions.md pages)
- "What does the user prefer?" → user model (`~/.pi/user/PROFILE.md`, `~/.pi/user/memory/`)
- "What's the current state of Z?" → project memory (status.md pages)

**Source reliability** (from SCHEMA.md):
- `codegraph/` → `high` (AST-parsed, deterministic)
- `sessions/` → `mixed` (LLM-generated)
- `docs/` → `high` (if human-authored)
- `external/` → `unverified` until cross-referenced

When citing wiki content, note the reliability tier of the source.

## §5 Gap detection

After checking the wiki, classify coverage:

| Finding | Action |
|---------|--------|
| Wiki has current, relevant content | Use it, cite it, move on |
| Wiki has content but stale (>30 days) | Note staleness, supplement with fresh research |
| Wiki has partial coverage | Use wiki for known parts, research for gaps |
| Wiki has nothing | Full external research needed |
| Wiki index mentions a topic but page is missing (broken link) | Flag as wiki gap |
| `SCHEMA.md` declares a topic category that's empty | Priority gap |

**Gap tracking:** When you detect a gap, mention it explicitly — "the wiki covers X
but is missing Y" — so the user or a wiki maintenance session can decide whether to
fill it.

## §6 Post-research gap filling

After external research, evaluate whether findings belong in the wiki.

### 6.1 Storage worthiness criteria

Ask these questions (from wiki principles in SCHEMA.md):

| Question | Store if... |
|----------|-------------|
| Is it about this project? | Yes → in scope. External-project facts → out of scope. |
| Will it be referenced again? | Yes → store. One-off trivia → skip. |
| Is it a decision or rationale? | Yes → always store (decisions.md). Rare to skip. |
| Is it code structure? | Yes → store as architecture/concept page, reference don't embed. |
| Is it an experiment result? | Yes → store in experiments/ with rationale. |
| Can it be derived deterministically? | Yes → tag source `codegraph/` (high reliability). |
| Is it from a web source? | Store only if cross-referenceable. Tag `external/` (unverified). |

### 6.2 How to propose storage

When findings meet storage criteria:

1. **Propose to the user** — never auto-ingest. Say: "The wiki is missing X.
   I found [source]. Should I store this as `projects/<name>/<page>.md`?"
2. **If approved** — follow the LLM Wiki skill's ingest flow (register source
   → compile page → update index.md → log entry)
3. **If deferred** — note the gap so it's visible in the next wiki audit

### 6.3 What NOT to store

- Raw source code (reference file paths, don't embed)
- Session transcripts verbatim (reference session path, extract patterns)
- Unverified web claims without cross-reference
- Trivial facts that will never be referenced again
- Content that duplicates existing wiki pages (update the existing page instead)

## §7 Integration with other wiki skills

This skill covers **consuming** the wiki. For **producing** wiki content:

| Task | Skill to load |
|------|---------------|
| Ingest sessions, compile pages, update index | LLM Wiki skill (`@micuintus/llm-wiki`) |
| Pi-specific session extraction recipes | `wiki-maintenance` skill |
| Codebase → project dossier pages | `wiki-maintenance` skill §2 |
| Web research to fill gaps | `wiki-maintenance` skill §3 |
| Wiki health audit | `wiki-audit` skill |
| Self-improvement (patterns → skill updates) | `wiki-maintenance` skill §4 |
| Lint checks, link integrity | LLM Wiki skill — Lint section |

## See also

- `~/.pi/llm-wiki/SCHEMA.md` — wiki conventions
- `~/.pi/llm-wiki/index.md` — browse entry
- `~/.pi/agent/llm-wiki/SCHEMA.md` — core memory conventions
- LLM Wiki SKILL.md (`@micuintus/llm-wiki/llm-wiki/SKILL.md`) — canonical ingest reference
- `wiki-maintenance` skill — operational layer
- `wiki-audit` skill — health checking
