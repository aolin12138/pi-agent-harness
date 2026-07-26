# Skills Catalog

Single human + agent readable index of all installed skills. Lives at `~/.pi/agent/INDEX.md` (sibling of AGENTS.md, outside the `skills/` directory so pi doesn't try to parse it as a skill file).

The "list skills first before any non-trivial task" rule in `AGENTS.md §1` requires this file to be read at the start of any non-trivial task so the agent can explicitly state which skills apply.

For the user: open this file to see what the agent can specialise in.
For the agent: list applicable rows before any further tool call when starting a non-trivial task.

## Loading model

| Tier | Mechanism | Cost |
|---|---|---|
| **Always-on essentials** | Inlined in AGENTS.md (orchestration, hard rules, journal essentials) | Free (cached) |
| **On-demand** | Read SKILL.md when the task triggers the row below | One read per use |
| **Description-only** | Trust the `description` in `<available_skills>` (rare/domain-specific) | Zero unless invoked |

The on-demand load happens **right before use** — content sits at the end of the conversation context, which is the strong-attention zone. Skills loaded mid-session and not used soon decay into the "lost in the middle" zone; if a skill should fire reliably late in a long session, its essentials belong in AGENTS.md, not here.

---

## §1. Orchestration & process

| Skill | Use when | Load when |
|---|---|---|
| `run-journal` | Non-trivial task that needs verifiable working memory (>5 tool calls, debugging, alignment matters) | **Inlined in AGENTS.md §4.** Read SKILL.md for depth on hard triggers, granularity, recovery rules. |
| `orchestrator-guidance` | Any time you need to step back and reorient on U→P→E→V | **Inlined in AGENTS.md §0.** Read SKILL.md for the long-form recognize-these-moments cues. |
| `subagent-progressive-disclosure` | Considering whether to delegate to a subagent (planner/executor/reviewer/scout/advisor) | When evaluating delegation — usually right before spawning |
| `ask-user` | About to ask the user for a decision, especially preference-sensitive or high-stakes | Right before composing an `ask_user` call |
| `grill-me-requirements` | Requirements are unclear and the user wants a structured interview | When the user says "what should I build" / "interview me" / similar |
| `plannotator-setup-goal` | User wants a long-running `/goal` work package with review gates | When the user mentions setting up a goal or backlog item |

## §2. Engineering discipline

| Skill | Use when | Load when |
|---|---|---|
| `debugging-protocol` | Something is broken and the cause is not obvious; before any non-trivial fix | At the start of debug work, before any edit. Per AGENTS.md §5. |
| `verification-protocol` | About to declare work done; designing the success-criteria section of a journal | Right before verification, or when filling journal §2 |
| `karpathy-guidelines` | Writing, reviewing, or refactoring code — anything that risks over-engineering | Right before non-trivial code edits, or when filling journal §3 (task decomposition) |

## §3. Agent safety

| Skill | Use when | Load when |
|---|---|---|
| `agent-self-preservation` | About to kill a process, or about to change a file that may require pi restart | Before any `pkill`/`taskkill`/`Stop-Process`/etc.; before any change to `~/.pi/agent/`, `~/.pi/llm-wiki/SCHEMA.md`, extensions, settings.json. **Hard rule pointers in AGENTS.md §1.** |

## §4. Wiki & knowledge

| Skill | Use when | Load when |
|---|---|---|
| `wiki-use` | About to research, navigate, or query the local wiki / past sessions | At the start of investigation work or "how does X work" questions |
| `wiki-maintenance` | Ingesting a session into the wiki, updating project pages, filling gaps | At session end when summarising, or when user says "update wiki" / "ingest this" |
| `wiki-audit` | Auditing wiki health — link integrity, stub aging, orphans, pre-commit review | When user says "audit wiki" / "wiki health" / before git commits to a wiki |
| `llm-wiki` | Generic LLM-wiki operations across personal knowledge bases (broader than pi's wiki) | When working in any wiki (pi's `llm-wiki/` or external) |
| `shared-language` | Starting work in an unfamiliar project where terminology needs alignment | At the start of a fresh project; building a CONTEXT.md |

## §5. Research

| Skill | Use when | Load when |
|---|---|---|
| `librarian` | Need to research open-source libraries with evidence-backed answers + GitHub permalinks | When user asks about library internals, implementation details, or wants citations to source code |

## §6. Domain — cloud, browser, automation

These skills have specific enough descriptions in `<available_skills>` that trigger-based loading works. Listed here for visibility, not for routing emphasis.

| Skill | Domain | Trigger |
|---|---|---|
| `azure-observability` | Azure Monitor, App Insights, Log Analytics, KQL, Workbooks | Azure monitoring questions |
| `microsoft-foundry` | Foundry agents: deploy, evaluate, fine-tune, optimize | Foundry-related work |
| `playwright-browser` | Browser automation with Playwright CLI | Web testing, scraping, form filling |

---

## How a "non-trivial task" use of this file looks

When the AGENTS.md "list skills first" rule fires, the agent does something like:

> *"This is a debugging task on a pi extension. From `~/.pi/agent/INDEX.md`:*
> - *§3 `agent-self-preservation` — the file is a pi-loadable extension, so I'll dry-load before suggesting restart*
> - *§2 `debugging-protocol` — for the diagnostic loop*
> - *§1 `run-journal` essentials are already in AGENTS.md §4; I'll start a journal*
>
> *Loading those three SKILL.md files now before further work."*

The act of listing them is the trigger that bridges the knowing-doing gap (per UCSD/UMD 2026 research): forcing the model to verbalise which skills apply increases the probability that the load action gets generated.

## Adding a new skill

When a new skill is introduced via the `wiki-maintenance` session-to-skill extraction step:

1. Add a row in the right category here.
2. If the skill needs to fire reliably late in a session (catch-22 or safety), add a hard-rule pointer in `AGENTS.md §1` and inline the essentials.
3. If the skill is loaded right before use, a dispatch entry in `AGENTS.md §8` is enough.
4. If the skill is rare/domain-specific, this catalog entry plus the `<available_skills>` description is enough.

## Cross-references

- `~/.pi/agent/AGENTS.md` — the always-on file; dispatch table is §8
- `~/.pi/agent/skills/<name>/SKILL.md` — depth for each skill (subdirectories only; pi loader treats those as the canonical skill files)
- `~/.pi/llm-wiki/built/skills.md` — historical narrative of how the skill catalog evolved (forensic, not for routing)
