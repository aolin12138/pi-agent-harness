---
title: "Wiki Version Control & Audit System"
type: concept
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/agent/skills/wiki-audit/SKILL.md
  - C:/Users/User/.pi/agent/workflows/wiki-audit.yaml
  - C:/Users/User/.pi/agent/workflows/wiki-daily-scan.yaml
  - C:/Users/User/.pi/bin/scan-unregistered-sessions.py
tags: [version-control, git, audit, automation]
---

# Wiki Version Control & Audit System

Version-controlled wikis with automated daily scanning and 4-day audit cycles.

## Git repos

| Wiki | Repo path | Purpose |
|------|-----------|---------|
| General memory | `~/.pi/llm-wiki/.git/` | Project knowledge base |
| Core memory | `~/.pi/agent/llm-wiki/.git/` | Cross-project behavioral patterns |

## Cycle

```
┌─────────────────────────────────────────────────┐
│  DAILY: scan-unregistered-sessions.py           │
│  Checks for new session JSONLs not in wiki      │
│  → Proposes ingestion priority                  │
├─────────────────────────────────────────────────┤
│  ON DEMAND: agent ingests flagged sessions      │
│  Uses wiki-maintenance skill                    │
│  → Stages changes (git working tree)            │
├─────────────────────────────────────────────────┤
│  EVERY ~4 DAYS: wiki-audit workflow             │
│  Reviewer agent with wiki-audit skill           │
│  → Checks git staged changes                    │
│  → Link integrity, structural health, quality   │
│  → Produces audit report with verdict           │
├─────────────────────────────────────────────────┤
│  IF APPROVED: git commit                        │
│  Commit message = [date] verb: what — why       │
│  IF CONDITIONAL: fix blockers, re-audit          │
│  IF REJECTED: report to user                    │
└─────────────────────────────────────────────────┘
```

## Components

| Component | Location | Role |
|-----------|----------|------|
| Session scanner | `bin/scan-unregistered-sessions.py` | Find unregistered sessions |
| wiki-audit skill | `agent/skills/wiki-audit/SKILL.md` | Teaches reviewer how to audit |
| wiki-audit workflow | `agent/workflows/wiki-audit.yaml` | 4-day audit via reviewer agent |
| wiki-daily-scan workflow | `agent/workflows/wiki-daily-scan.yaml` | Daily session scan + proposal |
| wiki-maintenance skill | `agent/skills/wiki-maintenance/SKILL.md` | Teaches agent how to ingest/update |

## Commit message format

```
[YYYY-MM-DD] <verb>: <what> — <why>

Changes:
- <file>: <summary>

Audit: ✅ approved (<N> issues, <M> auto-fixed)
```

Verbs match `log.md`: `scaffold`, `ingest`, `register`, `update`, `lint`, `restructure`, `create`.

## Pre-commit gate

Before any `git commit`, the wiki-audit workflow must:
1. Verify every staged file has a `log.md` entry
2. Check link integrity (all `](path.md)` resolve)
3. Verify See Also bidirectionality
4. Sample 3 pages for frontmatter + depth compliance
5. Produce a verdict: APPROVED / CONDITIONAL / REJECTED

No commit without APPROVED verdict.

## See also

- [wiki-maintenance skill](skills-wiki-maintenance.md)
- [workflows](workflows.md)
- [PKB plan](pkb-plan.md)
