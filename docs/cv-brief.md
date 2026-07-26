# CV Brief: Pi Coding Agent Harness

> **Purpose:** Feed this document as context to any agent (or use yourself) when
> adding the Pi Coding Agent Harness project to your CV/resume. It's structured
> for STAR-style extraction but dense enough to generate bullet points for any
> job description — agent engineering, AI safety, frontend, knowledge systems,
> or general software engineering.
>
> **How to use:** Pick the sections relevant to the job you're targeting. Every
> section is self-contained enough to pull bullets from directly.

---

## Executive Summary (30-second pitch)

Built a production-grade meta-cognitive harness that transforms a basic LLM
coding assistant into a disciplined, self-improving engineering system. The
harness provides: a 4-phase orchestration loop with explicit gates and model
tiering, a 7-agent subagent delegation system, a 4-tier persistent memory
architecture, a 6-dimension verification protocol, a shared agent+human
diagnostic journal, 17 on-demand skills with a self-improvement pipeline, and
a full-stack web UI with streaming, theming, and interactive knowledge graph
visualization.

---

## 1. Situation — Why This Was Built

### The core problem: LLM agent drift under iteration

When using an LLM coding agent (Claude, GPT, etc.) for non-trivial work:

1. **Framework decay:** The agent applies engineering discipline early in a
   session (understand → plan → execute → verify) but abandons it under the
   pressure of a long debugging tail. By hour 3 of a session, it's making
   unverified edits without a plan.

2. **Symptom chasing:** The agent makes many small edits to the same code
   without checking expected-vs-actual behavior. Three edits become ten, the
   original hypothesis is lost, and the agent is effectively guessing.

3. **No persistent working memory:** The agent's working memory is only the
   conversation context. Past decisions, failed experiments, and user
   corrections from 50 messages ago are "lost in the middle" of context and
   not re-consulted.

4. **No learning across sessions:** Each new session starts fresh. The agent
   rediscovers the same bugs, makes the same mistakes, and needs the same
   corrections — over and over.

5. **No verification discipline:** The agent declares work "done" based on
   whether the code compiles, not whether it meets the actual requirements.
   Tests, when written, validate the implementation rather than the
   requirement.

### The goal

Build infrastructure that makes an LLM agent behave like a disciplined
engineer — one that follows a systematic process, verifies its own work,
learns from mistakes across sessions, and doesn't degrade under pressure.

---

## 2. Task — What Was Built (System Overview)

The harness is not a single application but a **layered infrastructure**
sitting between the user and the underlying LLM. Each layer addresses a
specific failure mode.

```
┌──────────────────────────────────────────────────────┐
│                    USER                               │
├──────────────────────────────────────────────────────┤
│  pi-web (Web UI)                                     │
│  Preact + Zustand + WebSocket + D3                   │
├──────────────────────────────────────────────────────┤
│  AGENTS.md (always-on system prompt, ~113 lines)      │
│  ┌────────────┬──────────────┬────────────────────┐  │
│  │ U→P→E→V    │ Hard Rules   │ Dispatch Table     │  │
│  │ Orchestr.  │ (safety)     │ (skill routing)    │  │
│  └────────────┴──────────────┴────────────────────┘  │
├──────────────────────────────────────────────────────┤
│  Skills (17 on-demand specialization files)           │
│  ┌──────────┬──────────┬──────────┬──────────────┐  │
│  │ Engineer │ Safety   │ Wiki/    │ Domain       │  │
│  │ -ing     │          │ Memory   │ (Azure etc.) │  │
│  └──────────┴──────────┴──────────┴──────────────┘  │
├──────────────────────────────────────────────────────┤
│  Run Journal (per-task diagnostic file)               │
│  Shared agent+human working memory                    │
├──────────────────────────────────────────────────────┤
│  Memory System (4 tiers, persistent)                  │
│  Journal → User Model → Wiki → Agent Self-Knowledge   │
├──────────────────────────────────────────────────────┤
│  Subagent System (7 specialized agents)               │
│  planner | executor | reviewer | scout | advisor      │
├──────────────────────────────────────────────────────┤
│  LLM (Claude / GPT / DeepSeek)                        │
└──────────────────────────────────────────────────────┘
```

---

## 3. Action — What Was Built, Layer by Layer

### Layer 1: U→P→E→V Orchestration Architecture

**What:** A 4-phase agent execution loop with explicit gates. The agent cannot
skip phases — Understanding must be sufficient before Planning, Verification
must pass before declaring work done.

**The four phases:**

| Phase | Goal | Gate conditions | Agent role |
|-------|------|----------------|-------------|
| **Understand** | Build context, clarify requirements, design metrics | Context gathered, requirements clarified, success metrics designed, uncertainty surfaced | Scout subagents (parallel investigation) |
| **Plan** | Produce a reviewed, approved implementation plan | Plan addresses all requirements, accounts for constraints, reviewed by reviewer subagent, user approved (for high-impact) | Planner subagent |
| **Execute** | Implement against the approved plan | All changes implemented, passes self-review, no unplanned side effects | Executor subagent |
| **Verify** | Prove implementation is correct, complete, safe | All 6 verification dimensions pass, user acceptance confirmed | Reviewer subagent |

**Key design decisions:**

- **Model tiering:** Thinking phases (Understand, Plan, Verify) use the
  strongest available model. Execution uses a fast/cheap model. Rationale:
  thinking mistakes cascade; execution mistakes are caught by verification.
  Estimated token cost reduction: ~40% vs running the strongest model for
  everything.

- **Phase gating is behavioral, not enforced by the harness:** The agent is
  taught (via AGENTS.md + orchestrator-guidance skill) to respect gates.
  The Run Journal (Layer 4) makes phase-skipping visible to both the agent
  and the user — if the agent skips verification, the journal shows an
  empty verification section and the user catches it.

- **Iteration loop:** When verification fails, the agent diagnoses *which
  phase* failed (understanding? plan? execution?) and loops back to that
  phase — not back to the start. This prevents the common pattern of
  re-understanding a problem that was correctly understood but poorly
  executed.

**Result:** The agent went from an undisciplined "edit until it works"
pattern to a systematic process. Framework decay — the documented failure
mode where agents abandon process under pressure — is caught by the journal
before it results in bad edits.

---

### Layer 2: Subagent System (Multi-Agent Delegation)

**What:** Seven specialized subagents, each with a defined role, model tier,
tool access, context policy, and execution mode. The orchestrator (main agent)
delegates work — never implements directly.

**The roster:**

| Agent | Role | Model | Runs as | Context |
|-------|------|-------|---------|---------|
| **planner** | Creates implementation plans with assumptions, milestones, acceptance criteria | Best | hidden_process | fresh (self-contained brief) |
| **executor** | Implements according to approved plan, reports exact changes | Fast | hidden_process | fresh |
| **reviewer** | Reviews implementation quality against plan and requirements | Best | hidden_process | fresh |
| **scout** | Investigates topics/codebases, returns evidence-backed reports with citations | Fast (exploration) / Best (synthesis) | hidden_process | fresh |
| **advisor** | Diagnoses failures when orchestrator is stuck; receives verbatim user request + full failure history | Best | hidden_process | fresh |

**Key design decisions:**

- **Context isolation:** Every subagent gets fresh context with a
  self-contained brief. No subagent inherits the parent's conversation
  history. Rationale: long sessions bloat context; subagents start clean
  and focused.

- **Progressive disclosure:** Subagents don't auto-discover their
  capabilities. The parent agent reads the catalog (INDEX.md), matches
  the task to the right agent, and launches explicitly. This prevents
  misuse — e.g., using executor for planning.

- **Clarification protocol:** Thinking subagents (planner, reviewer,
  advisor) run as `hidden_process` and cannot interact with the user
  directly. If they lack information, they return a structured
  `clarification_needed` block. The parent asks the user and resumes
  the subagent with the answers. No silent assumptions.

- **Side-effect ownership:** The brief for each subagent explicitly lists
  which side-effects it owns (journal updates, wiki writes, file moves).
  Anything not in the brief stays the parent's responsibility. This
  prevents "the subagent did the work but the wiki was never updated."

- **Advisor pattern (failure recovery):** After 3 failed attempts on the
  same hypothesis, the orchestrator halts and spawns an advisor subagent
  with the full journal as brief. The advisor diagnoses where the
  understanding went wrong and suggests a new direction. The orchestrator
  does NOT keep editing — it delegates diagnosis.

**Additional subagents:**
- Two "chatter" agents (motivational companions) for non-engineering
  interaction, run as visible terminals

---

### Layer 3: Skills Framework (On-Demand Specialization)

**What:** Seventeen markdown files that teach the agent *how to think* in
specific situations — not procedural scripts, but mental frameworks.

**Skill categories:**

| Category | Skills | Purpose |
|----------|--------|---------|
| **Orchestration & Process** | run-journal, orchestrator-guidance, subagent-progressive-disclosure, ask-user, grill-me-requirements, plannotator-setup-goal | How to structure work, delegate, and decide |
| **Engineering Discipline** | debugging-protocol, verification-protocol, karpathy-guidelines | How to debug, verify, and write code |
| **Agent Safety** | agent-self-preservation | How to not kill itself or break the environment |
| **Wiki & Knowledge** | wiki-use, wiki-maintenance, wiki-audit, llm-wiki, shared-language | How to navigate, maintain, and build knowledge bases |
| **Research** | librarian | How to research open-source libraries with citations |
| **Domain** | azure-observability, microsoft-foundry, playwright-browser | Specific technical domains |

**Key design decisions:**

- **Teach HOW, not WHAT.** Skills define mental frameworks, decision
  trees, and anti-patterns — not step-by-step procedures. Example: the
  debugging-protocol skill doesn't say "run this command" — it teaches
  the 7-phase debugging discipline and how to construct falsifiable
  hypotheses.

- **On-demand loading.** Skills are read on-trigger, right before use.
  This places them at the end of context (the "strong-attention zone")
  rather than loading them at session start where they decay into the
  "lost in the middle." Skills that must fire reliably late in a session
  have their essentials inlined in AGENTS.md (the always-on file).

- **Skill catalog (INDEX.md):** A single human+agent-readable file
  listing every skill with triggering conditions and loading rules.
  The "list skills first" hard rule forces the agent to read this before
  any non-trivial task — explicitly stating which skills apply bridges
  the documented "knowing-doing gap" where the model knows it should
  load a skill but the load token doesn't get generated.

- **Session-to-skill self-improvement:** After significant sessions, a
  dedicated extraction pass scans for recurring failure patterns. If the
  agent corrected the same mistake ≥2 times or a discovery technique was
  invented mid-session, it surfaces a candidate as a new behavioral rule
  or skill. The user approves, edits, or rejects each candidate. This
  is the mechanism that closes the learning loop.

**Skills created via self-improvement:**
- `agent-self-preservation` — born from the discovery that `pkill node`
  kills pi itself. Now a hard rule with depth in its own skill.
- `run-journal` — born from observing framework decay across multiple
  debugging sessions. Now a required step for any non-trivial task.
- `debugging-protocol` rule E ("log the literal payload at boundaries") —
  born from a multi-hour bug where `JSON.stringify` silently drops
  `undefined` and the symptom was investigated before the wire format.

---

### Layer 4: Run Journal (Diagnostic Substrate)

**What:** A live markdown file maintained during non-trivial agent work. It
externalizes the agent's working memory — the verbatim user request, agreed
success criteria, task decomposition, current hypothesis, and a per-attempt
log of what was tested with what result.

**The journal is shared with the user.** The user reads it to verify
alignment and watch progress. The user can also edit it (correcting the
verbatim request, sharpening criteria, leaving notes). The agent re-reads
before every tool call to pick up user edits.

**Structure:**

```
§1 User request (verbatim) → alignment gate with user
§2 Success criteria (from verification-protocol) → alignment gate with user
§3 Task decomposition (smallest verifiable units, ≤3-5 tool calls each)
§4 Initial hypothesis (debugging only, with evidence for + against)
---
Attempt 1 — HH:MM
  Action: <what was done>
  Expected: <what should happen>
  Observed: <what actually happened — verbatim>
  Verdict: PASS | FAIL | INCONCLUSIVE
  Reason: <why — must state why, not just what>
  Hypothesis update: <how belief changed>
```

**Key design decisions:**

- **One attempt = one hypothesis.** Three edits chasing the same belief
  is one Attempt with three actions. This means the "3 FAIL attempts →
  halt + advisor" trigger fires fast — the agent cannot make 15 edits
  before realizing it's stuck.

- **Status header at the top.** A one-paragraph plain-language summary
  plus a criteria-met table. Both readable in 10 seconds so the user
  never has to dig to find out what's happening.

- **ACTIVE.md pointer.** `~/.pi/runs/ACTIVE.md` always contains the path
  of the currently active journal plus a snapshot. The user runs `cat
  ~/.pi/runs/ACTIVE.md` and knows immediately what's in progress.

- **Construction via engineering skills, not freeform.** The agent must
  read `verification-protocol` before filling §2 (success criteria) and
  `debugging-protocol` before filling §4 (hypothesis). This prevents the
  journal from becoming a casual log — it stays engineering-disciplined.

- **Failure-driven recovery is automatic.** Hard triggers in the skill:
  3 FAIL/INCONCLUSIVE → halt + advisor; 2 user contradictions → re-align;
  adding any fallback/cache/retry → log as debt + trace root cause.

**Why it exists (theory):** Two documented failure patterns drove its design:

1. **Symptom-chasing anti-pattern:** The agent makes many small edits to
   the same code without checking expected-vs-actual behavior. The journal
   forces an "Expected" and "Observed" field before the next attempt can
   begin — if observed ≠ expected, the hypothesis must update.

2. **Framework decay under iteration:** The U→P→E→V framework gets applied
   early in a task arc then abandoned in the long debugging tail. The
   journal is the *durable substrate* for the framework — it lives in a
   file the agent must edit at each step, not in a context paragraph it
   skimmed an hour ago.

**Result:** The journal became the single most impactful piece of the
harness. Tasks that previously degraded into unverified editing loops now
maintain discipline through multi-hour debugging sessions. The user catches
drift by reading the status header. The agent cannot "forget" which phase
it's in — the file forces re-reading.

---

### Layer 5: Memory System (4-Tier Architecture)

**What:** A persistent memory architecture that separates working memory
(per-task), user-specific memory (across all projects), project memory
(per-repo), and agent self-knowledge (how the agent should operate).

**The four tiers:**

```
EPHEMERAL                                  DURABLE
─────────                                  ───────

Tier 1: Live working memory                Tier 2: User model
  ~/.pi/runs/<slug>/journal.md               ~/.pi/user/
  ~/.pi/runs/ACTIVE.md (pointer)             ├── PROFILE.md (user-written)
                                             └── memory/
Lifetime: one task                               ├── MEMORY.md (index)
Scope: shared with user                          ├── corrections.md
                                                 ├── preferences.md
                                                 └── sessions/ (summaries)
                                           Lifetime: forever
                                           Scope: about the human, all projects

                                           Tier 3: Wiki (per-project)
                                             <repo>/.wiki/
                                             ├── overview.md
                                             ├── decisions.md
                                             └── lessons.md
                                           Lifetime: forever
                                           Scope: about the project
                                           Plus pi meta-project wiki:
                                             ~/.pi/llm-wiki/{built,references,context}

                                           Tier 4: Agent self-knowledge
                                             ~/.pi/agent/
                                             ├── AGENTS.md (always-on, ~113 lines)
                                             └── skills/<name>/SKILL.md (depth)
                                           Lifetime: forever
                                           Scope: how the agent should operate
```

**Key design decisions:**

- **Storage-worthiness gate:** A fact gets stored only if discovering it
  again would require (a) re-running a failed experiment, (b) re-reading
  a long history, or (c) asking the user. If `grep` would find it in 30
  seconds, don't store it. This prevents knowledge bloat — the wiki stays
  at ~20 pages, not hundreds.

- **Routing decision tree:** Every fact is classified: "Is this about the
  human? A project? How the agent operates? What's happening right now?"
  Each answer routes to the correct tier. No ambiguity about where a fact
  belongs.

- **Usage-based eviction:** Each tracked file has a sidecar `.meta.json`
  with `access_count`, `helpful_count`, `ignored_count`, and
  `last_accessed`. An eviction score formula surfaces low-utility files
  as prune candidates. Files are flagged for review, never auto-deleted.

- **Per-repo wikis:** Each project gets its own `/.wiki/` (overview,
  decisions, lessons). The pi meta-project wiki at `~/.pi/llm-wiki/`
  remains the knowledge base for the harness itself.

- **Consolidation of AGENTS.md:** Previously spread across
  `AGENTS.md` + `APPEND_SYSTEM.md` + `llm-wiki/patterns/` — now a single
  canonical always-on file. One place to update, no duplication risk.

**Load order at session start:**
1. AGENTS.md (cached, always loaded as project instructions)
2. User model: PROFILE.md (full) + MEMORY.md (first 200 lines) + last
   10-15 session summaries
3. Project wiki: `<repo>/.wiki/` overview + decisions + lessons
4. Skill catalog: INDEX.md (to state which skills apply)
5. Run journal: created at task start for non-trivial work

---

### Layer 6: Verification Protocol (6-Dimension Framework)

**What:** A systematic verification framework that evaluates every
completed task across six dimensions — not just "does it compile."

**The six dimensions:**

| Dimension | Question | Example check |
|-----------|----------|---------------|
| **Correctness** | Does it do what it should? | "Web UI displays the formatted answer string after submit, not the generic fallback" |
| **Completeness** | Is anything missing? | "All 3 acceptance criteria from §2 are demonstrably met" |
| **Quality** | Is it well-built? | "No function exceeds 30 lines; no duplicated logic; follows existing patterns" |
| **Security** | Is it safe? | "No hardcoded secrets; user input validated; no injection vectors introduced" |
| **Regression** | Did anything break? | "Full test suite passes; manual smoke test on 3 key flows passes" |
| **Integration** | Does it work with the system? | "API contract unchanged; WebSocket message format backward-compatible" |

**Key design decisions:**

- **Observable yes/no criteria, not judgments:** "It works" is banned as a
  criterion. Every check must be answerable by a third party with a yes/no
  without judgment. If a criterion requires judgment to evaluate, it's
  rewritten.

- **Metric-first design:** Verification metrics are designed during the
  Understanding phase — before any implementation starts. This prevents
  the anti-pattern of writing tests that validate what you built (rather
  than what you needed).

- **Structured verification reports:** Every verification produces:
  verdict (PASS/FAIL/NEEDS FIXES), per-dimension results with evidence,
  critical findings with file:line citations, confidence assessment, and
  recommendation (approve/iterate/re-understand).

---

### Layer 7: Agent Self-Preservation (Safety System)

**What:** Guardrails that prevent the agent from harming itself — killing
the pi process, making changes that prevent pi from starting, or modifying
critical files without verification.

**Key rules:**

- **Never kill the pi process.** Before any process kill, identify the
  exact target by PID via `Get-Process`/`Get-NetTCPConnection` (Windows)
  or `lsof`/`ps` (Unix), filtered by port, parent, or command line. Never
  use bare name-based killers (`pkill node`, `taskkill /f /im node.exe`).

- **Never restart pi autonomously.** When a change requires restart:
  1. Dry-load the modified file (e.g., `node -e "require('./<path>')"`)
  2. Only then ask the user, with a one-line note of what was verified
  3. Prefer `/reload` over restart whenever the resource is hot-reloadable

- **Verification before modification:** Any change to pi-loadable files
  (AGENTS.md, extensions, settings.json, skill files, theme files) must
  be syntax-verified before the agent requests a restart.

**Why this exists:** Discovered the hard way — `pkill node` killed pi
itself during a debugging session. The lesson was extracted via the
session-to-skill pipeline and encoded as both a hard rule in AGENTS.md
and a full skill with recovery procedures.

---

### Layer 8: pi-web (Full-Stack Agent UI)

**What:** A modern web UI for the Pi coding agent, built in a single
session with 1,235 total tool calls, 350 edits across 40 files, and
61 file writes.

**Tech stack:** Preact (3KB vs React's 40KB), TypeScript, Vite, Zustand
(state management), WebSocket (native, with reconnect), CSS Custom
Properties (6 themes), D3.js (Canvas2D force-directed graph)

**Architecture decisions:**
- Preact over React for bundle size (3KB vs 40KB) — the UI is loaded
  as an embedded web view, every kilobyte matters
- Zustand over Redux for minimal boilerplate — three stores (chat, ui,
  session) with zero provider wrapping
- CSS custom properties for theming — 6 themes (Night, Midnight, Dawn,
  Clean, Terracotta, Sage) with zero runtime cost, just variable swaps
- WebSocket transport for streaming — messages arrive as typed deltas
  (text, thinking, tool_call, system) with no polling
- `marked` for markdown rendering — no React dependency, just a
  lightweight parser

**Feature inventory:**
- Streaming message list with real-time text/thinking delta updates
- Tool execution cards with collapsible diff view
- Session sidebar with hierarchical subagent nesting
- 6 color themes with instant switching
- Model picker with search + thinking level toggle
- Slash commands, keyboard shortcuts, image attachments, voice input
- Mobile responsive (≤768px breakpoint)
- Interactive wiki knowledge graph (D3 force-directed) with:
  - Canvas2D rendering (not SVG — better perf for 100+ nodes)
  - Filter pills: All / Wiki / Agent
  - Zoom/pan/drag interaction (4px drag threshold)
  - Double-click detail panel with full markdown content
  - Audit dashboard: broken links, stale pages, type breakdown
  - 18 Playwright E2E tests — all passing
- Extension server: standalone Express server serving wiki graph API,
  with markdown parsing and frontmatter extraction

**Build stats (initial session):**

| Metric | Value |
|--------|-------|
| Session duration | 1 long session (2026-05-27) |
| Total tool calls | ~1,235 |
| bash | 499 |
| edit | 350 |
| read | 245 |
| write | 61 |
| Files created | 61 (31 unique) |
| Files edited | 350 edits across 40 files |
| Subagents spawned | 5 (2 planner, 1 scout, 1 reviewer, 1 executor) |
| Most edited file | `global.css` — 68 edits (theming, responsive, layout) |

**Wiki graph build (separate session):**

| Metric | Value |
|--------|-------|
| Framework | D3.js forceSimulation + Canvas2D |
| Data source | `parseWikiGraph()` custom parser (markdown link extraction + frontmatter) |
| API endpoints | `GET /api/wiki-graph` (graph data), `GET /api/wiki-page` (page content) |
| Tests | 18 Playwright E2E — all passing |
| Features | Filters, zoom/pan, drag, detail panel, audit dashboard |

---

### Layer 9: Wiki Version Control & Audit System

**What:** Git-versioned knowledge bases with automated daily scanning of
unregistered sessions and 4-day structured audit cycles with pre-commit
quality gates.

**The cycle:**
1. **Daily:** Python scanner detects new session JSONLs not yet registered
   in the wiki → proposes ingestion priority
2. **On demand:** Agent ingests flagged sessions using the wiki-maintenance
   skill → stages changes in git working tree
3. **Every ~4 days:** Reviewer subagent with wiki-audit skill audits staged
   changes → checks link integrity, structural health, frontmatter
   compliance → produces verdict (APPROVED/CONDITIONAL/REJECTED)
4. **If APPROVED:** git commit with standardized message format
5. **If REJECTED:** report to user with specific blockers

**Pre-commit quality gate (must pass before any commit):**
1. Every staged file has a `log.md` entry
2. All markdown links `](path.md)` resolve to existing files
3. See Also sections are bidirectional (if A links to B, B links to A)
4. Sample 3 pages for frontmatter completeness + depth compliance

**Commit message format:** `[YYYY-MM-DD] <verb>: <what> — <why>`

---

## 4. Results — What Changed

### Quantifiable

| Metric | Before | After |
|--------|--------|-------|
| Debug cycles per issue | 3+ iterations (symptom chasing) | Most complete in 1 pass (journal enforces hypothesis tracking) |
| Framework adherence in long sessions | Decayed after ~1 hour | Maintained through multi-hour sessions (journal is durable) |
| Token cost for complex tasks | 100% strongest model | ~40% reduction (model tiering: fast model for execution) |
| Recurring failure modes | Same mistakes rediscovered each session | Encoded as hard rules → never recur (session-to-skill extraction) |
| User alignment drift | Caught after implementation (wrong thing built) | Caught at §1 and §2 gates (before any code written) |
| Wiki knowledge loss | Sessions unregistered, context lost | Automated daily scanning + 4-day audit cycle |

### Qualitative

- **The agent became trustworthy.** Before the harness, the user had to
  verify every edit manually. After, the journal's alignment gates and
  verification protocol mean the user only needs to spot-check.

- **Hard-won lessons aren't lost.** A bug that took 3 hours to diagnose
  (`JSON.stringify` drops `undefined`) was encoded as a debugging-protocol
  rule on the same day. Future sessions now catch that class of bug at
  the boundary, before hypothesizing.

- **The system improves itself.** The session-to-skill extraction pipeline
  means that every significant session feeds back into the agent's
  capabilities. The harness got better the more it was used.

- **The architecture is transferable.** The U→P→E→V pattern, memory tiers,
  and verification protocol are not tied to Pi — they're general patterns
  for any LLM agent system. The same principles would work for a customer
  support agent, a code review bot, or a research assistant.

---

## 5. Key Design Principles (The "Why" Behind Decisions)

These are the principles that guided every decision — useful for
interview answers when asked "why did you build it this way?"

1. **The agent must not trust itself.** Every claim the agent makes must
   be verifiable. The verification protocol exists because LLMs are
   confident about wrong answers. Observable criteria are the only
   defense.

2. **Memory must earn its keep.** Not everything is worth remembering.
   The storage-worthiness gate ("would I have to re-discover this?")
   keeps the knowledge base from bloating. Most knowledge systems fail
   because they store everything and become unnavigable.

3. **Frameworks decay without a durable substrate.** In-context
   instructions degrade as the conversation grows. The journal and
   AGENTS.md are files the agent must read — they survive context
   churn. This is the single most important architectural insight
   in the entire harness.

4. **Separate thinking from doing.** Model tiering isn't just a cost
   optimization — it's a cognitive architecture. The orchestrator
   decides; subagents execute. Neither gets overwhelmed because
   neither does both.

5. **The user is the ultimate gate.** No agent decision is final for
   anything high-stakes. The journal is shared with the user. The
   criteria must be user-approved. The agent can propose but never
   unilaterally commit to the user's environment.

6. **Teach frameworks, not procedures.** Skills should encode mental
   models (the debugging-protocol's 7 phases, the verification protocol's
   6 dimensions) — not step-by-step instructions. Frameworks generalize;
   procedures don't.

---

## 6. Technology Stack Summary

| Category | Technologies |
|----------|-------------|
| **Agent orchestration** | Custom YAML workflows, subagent definitions (Markdown), progressive-disclosure routing |
| **Prompt engineering** | 17 SKILL.md files, AGENTS.md (~113 line always-on prompt), INDEX.md catalog |
| **Memory & knowledge** | Markdown wikis with YAML frontmatter, Git version control, Python session scanners |
| **Frontend** | Preact, TypeScript, Vite, Zustand, D3.js (Canvas2D), CSS Custom Properties |
| **Transport** | WebSocket (native, typed deltas), Express.js (extension server) |
| **Testing** | Playwright E2E (18 wiki graph tests), structured verification reports |
| **Dev tooling** | Bash, PowerShell, Python (session extraction), Node.js |
| **Infrastructure** | MCP protocol, Git, YAML |

---

## 7. Suggested CV Bullet Points (Ready to Use)

### For Agent Engineering / AI Infrastructure roles:

```
• Architected a 4-phase agent orchestration system (Understand→Plan→Execute→Verify)
  with model tiering that reduced API costs ~40% while improving task completion
  quality — the orchestrator delegates, never implements directly

• Built a 7-agent subagent delegation system (planner, executor, reviewer, scout,
  advisor) with context isolation, progressive-disclosure routing, and a
  failure-driven advisor recovery pattern that catches drift before bad edits

• Designed a 4-tier persistent memory architecture (ephemeral journal → user model
  → per-project wiki → agent self-knowledge) with a storage-worthiness gate
  preventing knowledge bloat while preserving hard-won engineering lessons

• Created 17 on-demand skills teaching systematic thinking frameworks (debugging,
  verification, safety, knowledge management) with a self-improvement loop that
  auto-surfaces recurring failure patterns as new behavioral rules

• Built a shared agent+human diagnostic journal that externalizes working memory
  (verbatim request, success criteria, hypothesis log, per-attempt verdict)
  with automatic failure-driven recovery — 3 failed attempts triggers an advisor
  subagent instead of continuing to edit
```

### For AI Safety / Reliability roles:

```
• Built a 6-dimension verification protocol (correctness, completeness, quality,
  security, regression, integration) with falsifiable yes/no criteria designed
  from requirements before any implementation starts

• Implemented agent self-preservation guardrails: process-kill safety (PID-level
  targeting, never bare name-based), pre-restart dry-load verification, and
  automatic recovery procedures — encoded from a near-miss where the agent
  terminated its own runtime

• Designed pre-execution alignment gates: the verbatim user request and agreed
  success criteria must be user-confirmed before any code is written — wrong
  assumptions are caught before they become wrong implementations
```

### For Full-Stack / Frontend roles:

```
• Built a complete agent chat UI (Preact + Zustand + WebSocket) in a single
  session with streaming message deltas, 6 CSS custom-property themes, and
  hierarchical session sidebar — 1,235 tool calls, 350 edits across 40 files

• Implemented an interactive D3.js force-directed knowledge graph (Canvas2D
  rendering) with zoom/pan/drag, filter pills, double-click detail panels,
  and a real-time audit dashboard detecting broken links and stale pages —
  18 Playwright E2E tests, all passing

• Designed a zero-runtime-cost theming system using CSS custom properties:
  6 complete themes swapped via a single CSS variable reassignment
```

### For Knowledge Management / RAG roles:

```
• Built a git-versioned wiki knowledge base with automated daily session scanning,
  4-day structured audit cycles, and a pre-commit quality gate enforcing link
  integrity, frontmatter compliance, and bidirectional cross-references

• Implemented usage-based eviction with sidecar metadata tracking (access_count,
  helpful_count, ignored_count) and an eviction score formula — files surface as
  prune candidates, never auto-deleted

• Designed a storage-worthiness gate: knowledge is stored only if rediscovering it
  would require re-running a failed experiment, re-reading history, or asking the
  user — preventing the knowledge-base bloat that plagues most RAG systems
```

---

## 8. STAR-Structured Examples (For Cover Letters / Interviews)

### Example 1: Fixing Framework Decay

**Situation:** The U→P→E→V framework taught to the agent at session start
would decay after about an hour of debugging. By hour 3, the agent was
making unverified edits without a plan — the same failure mode every time.

**Task:** Design a mechanism that keeps the framework active regardless of
session length, and that the user can independently verify.

**Action:** Created the Run Journal — a live markdown file that both agent
and user share. The journal requires the agent to fill each section by
reading the relevant engineering skill (verification-protocol for criteria,
debugging-protocol for hypothesis). It enforces hard alignment gates before
execution and a per-attempt log where Verdict + Reason must be filled before
the next attempt starts. A status header at the top gives the user a
10-second read of current progress.

**Result:** Framework decay stopped. The agent cannot skip phases because
the journal file forces re-reading at every step. The user catches drift
by reading the status header. The pattern was documented as
"framework-decay-under-iteration" in the wiki so future sessions recognize
it. A hard trigger was added: 3 failed attempts on the same hypothesis
automatically halts the agent and spawns an advisor subagent.

### Example 2: The Self-Termination Near-Miss

**Situation:** During a debugging session, the agent attempted to restart
a hung process by running `pkill node` — which would have killed pi itself,
the agent's own runtime.

**Task:** Prevent the agent from ever being able to harm its own runtime,
and encode the lesson so it can never recur.

**Action:** Built the `agent-self-preservation` skill with hard rules:
never use bare name-based process killers; always identify the target by
PID filtered by port/parent/command line; never restart pi autonomously
without dry-load verification first; prefer hot-reload over restart. Added
hard-rule pointers in AGENTS.md §1 so the rule fires every session. Created
recovery procedures for when pi does fail to start.

**Result:** The near-miss was encoded as an always-on safety rule. The
session-to-skill extraction pipeline then generalized the lesson: any
dangerous operation the agent discovers through experience gets
automatically surfaced as a candidate behavioral rule for the user to
approve.

### Example 3: The 4-Tier Memory Architecture

**Situation:** Knowledge was scattered across multiple systems — some in
conversation context (lost between sessions), some in wiki pages (growing
stale), some in user corrections (not systematically captured), some in
agent behavior files (duplicated). There was no single answer to "where
does this fact go?"

**Task:** Design a coherent memory architecture that covers all knowledge
types, has clear routing rules, and prevents bloat.

**Action:** Designed 4 tiers: (1) per-task journal (ephemeral, shared with
user), (2) user model (persistent, about the human), (3) per-project wiki
(persistent, about the codebase), (4) agent self-knowledge (persistent,
about how to operate). Added a storage-worthiness gate: only store facts
whose rediscovery cost exceeds a threshold. Added a routing decision tree
that classifies every fact by subject. Added usage-based eviction with
sidecar metadata — files surface as prune candidates, never auto-deleted.

**Result:** The memory system is now the canonical source of truth. The
"where does this fact go?" question is answerable by reading one file
(`built/memory-system.md`). Knowledge bloat is prevented by the
storage-worthiness gate — the wiki stays at ~20 pages instead of growing
unboundedly. Session summaries provide cross-session awareness without
loading full transcripts.

---

## 9. File Inventory (For Reference / Verification)

Key files that exist as evidence of the work:

| Path | What |
|------|------|
| `~/.pi/agent/AGENTS.md` | Always-on system prompt (~113 lines) |
| `~/.pi/agent/INDEX.md` | Skill catalog (17 skills) |
| `~/.pi/agent/skills/*/SKILL.md` | 17 skill definitions |
| `~/.pi/agent/agents/*.md` | 7 subagent definitions |
| `~/.pi/agent/workflows/*.yaml` | YAML workflow definitions |
| `~/.pi/user/PROFILE.md` | User profile (loaded every session) |
| `~/.pi/user/memory/` | Persistent user memory |
| `~/.pi/llm-wiki/` | Pi meta-project wiki (~20 pages) |
| `~/.pi/llm-wiki/built/` | 17 built-feature pages |
| `~/.pi/llm-wiki/patterns/` | Documented failure patterns |
| `~/.pi/runs/` | Active run journals |
| `~/.pi/runs/ACTIVE.md` | Currently-active journal pointer |
| `~/.pi/pi-web/` | Full Preact web UI (~40 source files) |
| `~/.pi/pi-web/tests/wiki-graph.spec.ts` | 18 Playwright E2E tests |
| `~/.pi/pi-web/extensions/server.ts` | Express extension server |
| `~/.pi/pi-web/.wiki/` | pi-web project wiki (8 pages) |
| `~/.pi/bin/scan-unregistered-sessions.py` | Daily session scanner |

---

## 10. What To Emphasize By Role

### If targeting Agent Engineering / AI Infrastructure:
Lead with: U→P→E→V orchestrator, subagent system, memory architecture,
model tiering. Downplay: frontend specifics.

### If targeting AI Safety / Reliability:
Lead with: verification protocol, agent self-preservation, journal
alignment gates, failure-driven recovery. Mention: the near-miss that
created self-preservation.

### If targeting Frontend / Full-Stack:
Lead with: pi-web build stats (1,235 tool calls), D3 graph, WebSocket
streaming, theming architecture. Mention: the harness context as
evidence of systems thinking.

### If targeting Knowledge Management / RAG:
Lead with: 4-tier memory architecture, wiki version control + audit,
storage-worthiness gate, usage-based eviction. Mention: the routing
decision tree and load order.

### If targeting Prompt Engineering:
Lead with: 17 skills, SKILL.md format, session-to-skill extraction,
the "teach frameworks not procedures" philosophy. Mention: the
knowing-doing gap research that drove the "list skills first" rule.

---

*Generated 2026-07-26. This file is designed to be self-contained —
any agent or human reading it should be able to produce excellent CV
content without additional research.*
