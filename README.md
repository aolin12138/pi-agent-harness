# pi-agent-harness

**A production-grade meta-cognitive harness that transforms an LLM coding agent
into a disciplined, self-improving engineering system.**

Built over 30+ sessions. 11 custom skills. 5 specialized subagents. 4-tier
persistent memory. 6-dimension verification protocol. Full-stack web UI with
streaming, theming, and interactive knowledge graph.

---

## What problem does this solve?

LLM coding agents suffer from five documented failure modes:

| Failure Mode | What Happens | How This Harness Fixes It |
|-------------|--------------|--------------------------|
| **Framework decay** | Agent applies process early, abandons it under debugging pressure | U→P→E→V orchestrator with durable run journal — the framework lives in a file, not fading context |
| **Symptom chasing** | Agent makes unverified edits without checking expected-vs-actual behavior | Per-attempt journal log: Expected → Observed → Verdict → Hypothesis update. No next attempt without previous verdict. |
| **Lost working memory** | Past decisions and failed experiments "lost in the middle" of context | Run journal externalizes working memory; 3 FAIL trigger auto-halts and spawns advisor subagent |
| **No cross-session learning** | Each session starts fresh, rediscovers same mistakes | Session-to-skill extraction pipeline auto-surfaces recurring failure patterns as new behavioral rules |
| **No verification discipline** | "Done" = compiles, not = meets requirements | 6-dimension verification protocol designed from requirements before implementation starts |

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                      USER                                 │
├──────────────────────────────────────────────────────────┤
│  pi-web — Preact + Zustand + WebSocket + D3              │
│  Streaming chat, 6 themes, wiki knowledge graph           │
├──────────────────────────────────────────────────────────┤
│  AGENTS.md — always-on prompt (~138 lines)                │
│  ┌──────────────┬──────────────┬──────────────────────┐  │
│  │ U→P→E→V      │ Hard Rules   │ Dispatch Table       │  │
│  │ Orchestrator │ (safety)     │ (skill routing)      │  │
│  └──────────────┴──────────────┴──────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  Skills — 11 custom + 6 external on-demand specializations│
│  ┌────────────┬────────────┬────────────┬─────────────┐  │
│  │ Engineering│ Safety     │ Wiki/      │ Orchestr.   │  │
│  │ Discipline │            │ Memory     │ & Process   │  │
│  └────────────┴────────────┴────────────┴─────────────┘  │
├──────────────────────────────────────────────────────────┤
│  Run Journal — shared agent+human diagnostic file         │
│  Verbatim request → criteria → hypothesis → attempt log   │
├──────────────────────────────────────────────────────────┤
│  Memory System — 4-tier architecture                      │
│  Journal (ephemeral) → User Model → Wiki → Self-Knowledge │
├──────────────────────────────────────────────────────────┤
│  Subagent System — 5 specialized agents                   │
│  planner | executor | reviewer | scout | advisor          │
├──────────────────────────────────────────────────────────┤
│  LLM (Claude / GPT / DeepSeek)                            │
└──────────────────────────────────────────────────────────┘
```

### The U→P→E→V Orchestrator

The agent never jumps straight to coding. Every non-trivial task flows through
four explicit phases:

| Phase | Goal | Subagent | Gate |
|-------|------|----------|------|
| **Understand** | Clarify requirements, design success metrics | Scout(s) | Requirements confirmed, metrics designed |
| **Plan** | Produce reviewed, approved implementation plan | Planner → Reviewer | Plan reviewed, user approved (for high-impact) |
| **Execute** | Implement against approved plan | Executor | All changes pass self-review |
| **Verify** | Prove correctness, completeness, safety | Reviewer | All 6 verification dimensions pass |

**Model tiering:** Thinking phases (Understand, Plan, Verify) use the strongest
model. Execution uses a fast/cheap model. ~40% token cost reduction without
quality loss — thinking mistakes cascade, execution mistakes are caught.

### Subagent System

Five specialized subagents, each with defined role, model tier, and context
policy. The orchestrator delegates — never implements directly.

| Agent | Role | Model | Trigger |
|-------|------|-------|---------|
| **planner** | Creates implementation plans with assumptions, milestones, acceptance criteria | Best | Before any implementation |
| **executor** | Implements against approved plan, reports exact changes | Fast | After plan approved |
| **reviewer** | Reviews implementation quality against plan and requirements | Best | After execution; before declaring done |
| **scout** | Investigates topics/codebases, returns evidence-backed reports | Best | Parallel exploration during Understanding |
| **advisor** | Diagnoses failures when orchestrator is stuck | Best | After 3 FAIL attempts on same hypothesis |

### Memory Architecture (4 Tiers)

Every fact has a home. No ambiguity about where knowledge lives.

| Tier | What | Lifetime | Example |
|------|------|----------|---------|
| **1 — Journal** | Current task working memory | One task | Hypothesis log, attempt verdicts |
| **2 — User Model** | Human preferences, corrections, session summaries | Forever | "Prefers functional style over classes" |
| **3 — Wiki** | Project overview, architecture, decisions, lessons | Forever | "Chose SQLite over Postgres for offline-first" |
| **4 — Self-Knowledge** | How the agent should operate | Forever | "Never kill pi process" |

**Storage-worthiness gate:** A fact is stored only if rediscovering it would
require re-running a failed experiment, re-reading a long history, or asking
the user. If `grep` finds it in 30 seconds, it's not stored.

### Verification Protocol (6 Dimensions)

Verification metrics are designed from requirements **before** implementation
starts — not written after to validate what was built.

| Dimension | Question | Example Check |
|-----------|----------|---------------|
| Correctness | Does it do what it should? | "Web UI displays the formatted answer, not the generic fallback" |
| Completeness | Is anything missing? | "All 3 acceptance criteria demonstrably met" |
| Quality | Is it well-built? | "No function exceeds 30 lines; no duplicated logic" |
| Security | Is it safe? | "No hardcoded secrets; user input validated" |
| Regression | Did anything break? | "Full test suite passes; manual smoke test passes" |
| Integration | Does it work with the system? | "API contract unchanged; WebSocket format backward-compatible" |

Every criterion is a **yes/no observable** — if judgment is needed to evaluate
it, the criterion is rewritten.

### Run Journal

The single most impactful component. A live markdown file shared between agent
and user that externalizes working memory into a durable substrate.

```
§1 User request (verbatim) → alignment gate with user
§2 Success criteria (from verification-protocol) → alignment gate with user
§3 Task decomposition (smallest verifiable units)
§4 Hypothesis (debugging only, with evidence for + against)

Attempt 1 — 14:23
  Action: Modified rpc-handler.ts:45 — added JSON.stringify log at boundary
  Expected: Payload shape should match client expectation
  Observed: {type: "result", text: undefined} — JSON.stringify drops undefined
  Verdict: FAIL
  Reason: Undefined values silently dropped during serialization
  Hypothesis update: Bug is at serialization boundary, not client parsing
```

Hard rules enforced by the journal:
- **Verdict + Reason for Attempt N must be filled before Attempt N+1 starts.**
- **3 FAIL/INCONCLUSIVE on same hypothesis → halt + spawn advisor subagent.**
- **2 user contradictions → re-align before any further edit.**
- **Cannot state hypothesis in one sentence → stop and re-read last 3 attempts.**

---

## Skills

Eleven custom skills that teach the agent *how to think* — not procedural
scripts, but mental frameworks and decision trees.

| Skill | Purpose | Category |
|-------|---------|----------|
| `orchestrator-guidance` | U→P→E→V framework: active questioning, uncertainty management, subagent coordination | Orchestration |
| `run-journal` | Diagnostic journal for non-trivial tasks: criteria, decomposition, hypothesis loop | Process |
| `subagent-progressive-disclosure` | Delegation policy: routing, context isolation, chain/retry behavior | Orchestration |
| `debugging-protocol` | Systematic debugging: feedback loops, 7-phase discipline, falsifiable hypotheses | Engineering |
| `verification-protocol` | 6-dimension verification with observable criteria and metric-first design | Engineering |
| `karpathy-guidelines` | Behavioral rules to reduce common LLM coding mistakes | Engineering |
| `agent-self-preservation` | Process-kill safety, pre-restart dry-load, recovery procedures | Safety |
| `wiki-use` | Wiki-first navigation: memory retrieval, gap detection, storage-worthiness | Knowledge |
| `wiki-maintenance` | Session extraction, codebase exploration, self-improvement loop | Knowledge |
| `wiki-audit` | Wiki health: link integrity, stub aging, pre-commit quality gate | Knowledge |
| `shared-language` | Domain glossary for precise vocabulary across agents | Knowledge |
| `grill-me-requirements` | Structured requirement interviews with interactive option picking | Process |

Skills are loaded **on-demand, right before use** — landing at the end of
context (strong-attention zone) rather than decaying from the start of a
long session.

---

## Self-Improvement Pipeline

The harness gets better the more it's used.

```
Session work → wiki-maintenance extraction pass →
  "Is there anything in this session future sessions need
   encoded as a behavioral rule, not just a memory?"

  Candidate surfaced → User approves / edits / rejects →
    → AGENTS.md hard rule or new SKILL.md or INDEX.md update

  Next session benefits from the encoded lesson.
```

**Examples of rules born from this pipeline:**
- **"Never kill pi"** → `agent-self-preservation` skill (after `pkill node` near-miss)
- **"Log the literal payload at boundaries"** → `debugging-protocol` rule E (after 3-hour `JSON.stringify undefined` bug)
- **"One advisor solves one diagnostic question"** → hard rule (after multi-topic advisor confusion)
- **"Never write session analysis from memory — grep the JSONL"** → hard rule (after two incorrect summaries)

---

## pi-web — Full-Stack Agent UI

A modern web UI built in a single session. [Separate repo →](https://github.com/user/pi-web)

| Metric | Value |
|--------|-------|
| Framework | Preact + TypeScript + Vite |
| State | Zustand (3 stores) |
| Transport | WebSocket (native, typed deltas) |
| Styling | CSS Custom Properties (6 themes, zero runtime cost) |
| Build stats | 1,235 tool calls, 350 edits, 61 writes, 5 subagents |
| Tests | 18 Playwright E2E (wiki graph) — all passing |

**Features:** streaming messages, collapsible tool diff cards, hierarchical
session sidebar, model picker with thinking toggle, slash commands, image
attachments, mobile responsive.

**Wiki Knowledge Graph:** D3.js force-directed Canvas2D graph with:
- Cell nucleus layout (pages orbit wiki roots at fixed radius)
- Filter pills (All / Wiki / Agent)
- Zoom/pan/drag with 4px drag threshold
- Double-click detail panel with full markdown rendering
- Audit dashboard: broken links, stale pages (>30 days), type breakdown

---

## Wiki Knowledge Base

A git-versioned, quality-gated knowledge base with automated maintenance.
The `wiki/` directory contains the full pi meta-project wiki — 46 pages
covering every built feature, architectural decision, failure pattern, and
operational reference.

**Automated cycle:**
1. **Daily:** Python scanner detects unregistered sessions → proposes ingestion
2. **On demand:** Agent ingests sessions → stages git changes
3. **Every ~4 days:** Reviewer subagent audits staged changes:
   - Link integrity (all `](path.md)` resolve)
   - See Also bidirectionality
   - Frontmatter compliance + depth
   - Verdict: APPROVED / CONDITIONAL / REJECTED
4. **If APPROVED:** git commit. If REJECTED: report blockers.

---

## Results

| Metric | Before | After |
|--------|--------|-------|
| Debug cycles per issue | 3+ iterations (symptom chasing) | Most complete in 1 pass |
| Framework adherence in long sessions | Decayed after ~1 hour | Maintained through multi-hour sessions |
| Token cost for complex tasks | 100% strongest model | ~40% reduction (model tiering) |
| Recurring failure modes | Same mistakes rediscovered each session | Encoded as hard rules → never recur |
| User alignment drift | Caught after implementation | Caught at pre-execution gates |

---

## Quick Start — Using This Harness

### Prerequisites
- [Pi coding agent](https://github.com/eko24ive/pi) installed
- Git
- Node.js

### Setup (any machine)

```bash
# 1. Clone
git clone https://github.com/<your-username>/pi-agent-harness.git
cd pi-agent-harness

# 2. Install to ~/.pi
# Windows:
.\setup.ps1
# macOS/Linux/WSL:
./setup.sh

# 3. Install external dependencies
pi install npm:pi-web-access
pi install npm:@eko24ive/pi-ask
pi install npm:@micuintus/llm-wiki
pi install npm:pi-playwright
pi install npm:pi-mcp-adapter

# 4. Configure
# Edit ~/.pi/agent/settings.json with your API keys and model preferences
# Edit ~/.pi/user/PROFILE.md with your preferences

# 5. Configure personal layer (see PORTABILITY.md for full guide)
#    - Set API key environment variables
#    - Authenticate with pi for your LLM providers
#    - Copy PROFILE.md from old machine or write from scratch

# 6. Start
pi
```

### Updating

```bash
git pull
./setup.ps1   # or ./setup.sh
```

### What gets installed

| Destination | Content |
|-------------|---------|
| `~/.pi/agent/AGENTS.md` | Always-on system prompt |
| `~/.pi/agent/INDEX.md` | Skill catalog |
| `~/.pi/agent/skills/` | 11 custom skills |
| `~/.pi/agent/agents/` | 5 subagent definitions |
| `~/.pi/agent/workflows/` | 4 YAML workflows |
| `~/.pi/llm-wiki/` | Full knowledge base (46 pages) |
| `~/.pi/user/` | PROFILE.md + memory structure (templates) |

**Never installed (excluded by .gitignore):** sessions, runs, auth tokens,
API keys, personal memory.

---

## Repository Structure

```
pi-agent-harness/
├── README.md                     # Architecture overview + setup guide
├── PORTABILITY.md                # Moving between machines: what to copy, what to reconfigure
├── setup.ps1 / setup.sh          # One-command install
├── .gitignore
├── agent/
│   ├── AGENTS.md                 # Always-on prompt (138 lines)
│   ├── INDEX.md                  # Skill catalog
│   ├── settings.template.json    # Config template (no secrets)
│   ├── skills/                   # 11 custom skills
│   │   ├── agent-self-preservation/
│   │   ├── debugging-protocol/
│   │   ├── grill-me-requirements/
│   │   ├── orchestrator-guidance/
│   │   ├── run-journal/
│   │   ├── shared-language/
│   │   ├── subagent-progressive-disclosure/
│   │   ├── verification-protocol/
│   │   ├── wiki-audit/
│   │   ├── wiki-maintenance/
│   │   └── wiki-use/
│   ├── agents/                   # 5 subagent definitions
│   │   ├── advisor.md
│   │   ├── executor.md
│   │   ├── planner.md
│   │   ├── reviewer.md
│   │   └── scout.md
│   └── workflows/                # 4 YAML workflows
├── wiki/                         # Knowledge base (46 pages)
│   ├── index.md
│   ├── built/                    # Feature documentation
│   ├── context/                  # Project overview + architecture
│   ├── references/               # Operational references
│   ├── patterns/                 # Documented failure patterns
│   └── raw-sources/              # Source material index
└── docs/
    └── cv-brief.md               # Comprehensive CV brief
```

---

## Key Design Principles

1. **The agent must not trust itself.** Every claim must be verifiable.
   Observable yes/no criteria are the only defense against LLM confabulation.

2. **Memory must earn its keep.** The storage-worthiness gate prevents
   knowledge bloat. Most knowledge systems fail by storing everything.

3. **Frameworks decay without a durable substrate.** In-context instructions
   degrade as conversation grows. Files the agent must re-read survive
   context churn. This is the single most important architectural insight.

4. **Separate thinking from doing.** The orchestrator decides; subagents
   execute. Model tiering matches cognitive demand to model quality.

5. **Teach frameworks, not procedures.** Skills encode mental models, not
   step-by-step instructions. Frameworks generalize; procedures don't.

---

## Technologies

`TypeScript` `Preact` `Zustand` `D3.js` `WebSocket` `CSS Custom Properties`
`Playwright` `Vite` `Express` `Python` `Bash` `PowerShell` `Git` `YAML`
`Markdown` `MCP Protocol`

---

## License

MIT

---

*Built iteratively across 30+ sessions. The harness improved itself along
the way — every significant session fed back into its own design through
the self-improvement pipeline.*
