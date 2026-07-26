---
title: "PKB / LLM Wiki Plan (ARCHIVED)"
type: archive
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/PLAN-pkb-llm-wiki.md
tags: [pkb, llm-wiki, knowledge-base, architecture]
---

# PKB / LLM Wiki — Implementation Status

## Current system

The knowledge base uses the **LLM Wiki extension** (`@micuintus/llm-wiki`) — an installed Pi package providing the markdown-based wiki pattern (SCHEMA, index, log, raw-sources, topic pages). This replaced the earlier plan to build a custom PKB TypeScript extension.

## What happened to the custom PKB extension

A custom PKB Wiki TypeScript extension (`pkb-wiki.ts`, 25KB) was built matching the plan below, but was **disabled on 2026-05-27** in favor of the LLM Wiki package. The custom extension has been deleted.

## Overview

The PKB system continuously learns from Pi sessions and subagent runs, providing concise, non-redundant guidance. It has two scopes:

- **Global wiki** (core memory): cross-project behavioral patterns
- **Project wiki** (general memory): repo-specific context, progress, latest state

## Architecture

```
┌─────────────────────────────────────────────┐
│  pkb-wiki.ts extension                      │
│  (event capture, candidate extraction)       │
├─────────────────────────────────────────────┤
│  wiki agent (agent/agents/wiki.md)          │
│  (curation, compilation, dedup)              │
├─────────────────────────────────────────────┤
│  wiki-ingest-and-audit workflow             │
│  (collect → extract → dedupe → audit → pub) │
├─────────────────────────────────────────────┤
│  Storage: docs-as-code markdown + JSONL idx │
│  Global: ~/.pi/agent/wiki/                  │
│  Project: .pi/llm-wiki/                     │
└─────────────────────────────────────────────┘
```

## Data model

Each extracted item is an entry record:

| Field | Description |
|-------|-------------|
| `entry_id` | Unique identifier (pkb_...) |
| `scope` | global or project |
| `entry_type` | semantic_fact, episodic_pattern, procedural_pattern, audit_event |
| `status` | candidate, approved, deprecated, superseded |
| `pattern` | trigger condition + action sequence + anti-patterns |
| `confidence` | 0.0–1.0 score with rationale |
| `evidence` | session file, entry IDs, tools, subagents, files, URLs |
| `dedupe` | canonical key hash + duplicate/supersede references |

## Implementation phases

| Phase | Scope | Status |
|-------|-------|--------|
| Phase 1 | Extension skeleton, event capture, storage layout, /wiki:sync, /wiki:query, /wiki:audit | Not started |
| Phase 2 | wiki agent, ingest workflow, manual review queue, global/project routing | Not started |
| Phase 3 | Widget/status panel, audit scorecard, promotion lifecycle | Not started |
| Phase 4 | Semantic dedupe, periodic audits, visualization exports | Not started |

## Alternatives considered

| Alternative | Why rejected |
|-------------|-------------|
| Vector DB (Chroma/Pinecone) | Overkill for v1; adds infra dependency; markdown is more auditable |
| Single monolithic wiki | Can't separate global behavioral patterns from project facts |
| Full NLP extraction | Expensive, unreliable; structural JSONL analysis is more deterministic |
| Auto-publish without review | Risk of compounding LLM fabrications; human review gate is essential |

## Key decisions

1. **Markdown storage over DB** — auditable, git-friendly, human-readable
2. **Structural extraction over NLP** — JSONL event stream analysis is deterministic
3. **Two-tier (global + project)** — behavioral patterns and project facts have different lifecycles
4. **Human review gate** — prevents auto-compounding of LLM errors

## See also

- [project overview](../context/overview.md)
- [SCHEMA.md](../SCHEMA.md)
