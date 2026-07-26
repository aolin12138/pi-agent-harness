---
title: "Skills"
type: reference
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/agent/skills/
  - C:/Users/User/.agents/skills/
tags: [skills, guidance, specialization]
---

# Skills

Skills provide specialized guidance to the agent for specific tasks. Loaded on-demand when the task matches.

## Installed skills

| Skill | Location | Purpose |
|-------|----------|---------|
| grill-me-requirements | `~/.pi/agent/skills/` | Requirement interrogation with interactive option picking |
| subagent-progressive-disclosure | `~/.pi/agent/skills/` | Progressive-disclosure delegation policy for subagents |
| azure-observability | `~/.agents/skills/` | Azure Monitor, App Insights, Log Analytics, Alerts, Workbooks |
| karpathy-guidelines | `~/.agents/skills/` | Behavioral guidelines to reduce common LLM coding mistakes |
| microsoft-foundry | `~/.agents/skills/` | Deploy, evaluate, fine-tune Foundry agents end-to-end |
| plannotator-setup-goal | `~/.agents/skills/` | Create reviewed Codex goal setup packages |
| librarian | `AppData/Roaming/npm/node_modules/pi-web-access/skills/` | Research open-source libraries with evidence-backed answers |
| ask-user | `AppData/Roaming/npm/node_modules/@eko24ive/pi-ask/skills/` | Decision/research/requirements gate before ambiguous choices |
| llm-wiki | `AppData/Roaming/npm/node_modules/@micuintus/llm-wiki/llm-wiki/` | LLM-curated personal knowledge base |
| playwright-browser | `~/.pi/agent/npm/node_modules/pi-playwright/skills/` | Browser automation with Playwright CLI |
| wiki-maintenance | `~/.pi/agent/skills/wiki-maintenance/` | Ingest, update, research workflows for LLM Wiki. Self-improving from core memory |
| wiki-use | `~/.pi/agent/skills/wiki-use/` | Wiki-first research protocol: navigation, memory retrieval, gap detection, storage-worthiness |
| wiki-audit | `~/.pi/agent/skills/wiki-audit/` | Wiki health auditing: link integrity, git review, structural health, pre-commit gate |
| orchestrator-guidance | `~/.pi/agent/skills/orchestrator-guidance/` | U→P→E→V framework: systematic task completion with active questioning, uncertainty management, subagent coordination |
| verification-protocol | `~/.pi/agent/skills/verification-protocol/` | Six-dimension verification framework: correctness, completeness, quality, security, regression, integration. Includes vertical TDD principles. |
| debugging-protocol | `~/.pi/agent/skills/debugging-protocol/` | Systematic debugging: feedback loop construction, 7-phase discipline, falsifiable hypotheses |
| shared-language | `~/.pi/agent/skills/shared-language/` | Domain glossary (CONTEXT.md) — precise vocabulary shared across all agents, reduces token waste |

## See also

- [agent agents](agent-agents.md)
- [extensions](extensions.md)
- [wiki-maintenance skill](skills-wiki-maintenance.md)
