---
title: "wiki-maintenance Skill"
type: concept
updated: 2026-05-31
sources:
  - C:/Users/User/.pi/agent/skills/wiki-maintenance/SKILL.md
tags: [skills, wiki-maintenance, self-improving]
---

# wiki-maintenance Skill

Thin operational companion to the LLM Wiki skill. Adds three things the base skill doesn't cover:

| Addition | Why it exists |
|----------|---------------|
| **Pi session Python recipe** | The base skill's jq patterns don't match current Pi JSONL format (tool calls are inline in content blocks, not `custom` events) |
| **Web research for gaps** | The base skill assumes sources are provided. This skill teaches the agent to find complementary sources online |
| **Self-improvement loop** | Patterns from sessions → core memory → skill updates. The base skill has no meta-cognition |

## What it does NOT duplicate

The base LLM Wiki skill remains canonical for: ingest flow, page types, frontmatter, depth rules, lint checks, quality gates, correction pattern, navigation patterns, and schema management. This skill **points to** those, never re-explains them.

## Size comparison

| Version | Size | Duplication |
|---------|------|-------------|
| v1 (initial) | 11,164 bytes | Heavy — re-explained ingest, lint, quality gates |
| v2 (current) | 5,115 bytes | None — only adds what's missing |

## See also

- [skills catalog](skills.md)
- [PKB plan](pkb-plan.md)
