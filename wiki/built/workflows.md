---
title: "Workflows"
type: concept
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/agent/workflows/
  - C:/Users/User/.pi/PLAN-workflow-create.md
tags: [workflows, yaml, automation]
---

# Workflows

YAML-defined multi-step workflows for the Pi agent.

## Workflow engine

Workflows are defined as YAML files and executed via `/run-workflow <name>`. They orchestrate multiple agent turns or subagent delegations.

### Known workflows

| Workflow | File | Purpose |
|----------|------|---------|
| plan-and-review | `plan-and-review.yaml` | Plan → execute → review chain |
| wiki-audit | `wiki-audit.yaml` | 4-day wiki health audit + pre-commit git review |
| wiki-daily-scan | `wiki-daily-scan.yaml` | Daily scan for unregistered sessions, propose ingestion |
| wiki-ingest | `wiki-ingest.yaml` | Full ingestion pipeline: validate → extract → dedupe → compile → index → log → audit |

## Workflow stages

Typical workflow pattern:
1. **collect** — gather evidence (sessions, artifacts)
2. **extract** — produce candidate entries
3. **dedupe** — merge/update canonical entries
4. **audit** — validate health + quality gates
5. **publish** — write markdown/index/log

## See also

- [PKB plan](pkb-plan.md)
- [extensions](extensions.md)
