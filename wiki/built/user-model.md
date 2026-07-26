---
title: "User Model — Persistent User Memory"
type: concept
updated: 2026-06-06
status: active
tags: [user-model, memory, personalization, preferences]
---

# User Model

Persistent user memory system at `~/.pi/user/`. The agent learns the user's
preferences, personality, habits, and past decisions across sessions, loading
this context at session start for personalized assistance.

Replaces the deprecated core memory (`~/.pi/agent/llm-wiki/patterns/`) which
stored generic behavioral patterns that were redundant with skills.

## Directory structure

```
~/.pi/user/
├── PROFILE.md              # User-written preferences (always loaded fully)
├── memory/
│   ├── MEMORY.md            # Agent-written index (first 200 lines at start)
│   ├── preferences.md       # Coding style, tool choices, conventions
│   ├── corrections.md       # Past mistakes and what was learned
│   ├── workflows.md         # Common task patterns
│   ├── projects/<hash>/     # Per-project memory
│   │   └── MEMORY.md
│   └── sessions/            # Recent session summaries (one file per day)
│       └── YYYY-MM-DD.md    # One paragraph: what was done, decisions, context
```

## Two layers

| Layer | Who writes | What | Loaded when |
|-------|-----------|------|-------------|
| PROFILE.md | User | Standing preferences, personality, "always/never" rules | Every session, fully |
| memory/MEMORY.md | Agent | Pointer index to topic files | First 200 lines at session start |
| memory/sessions/ | Agent | One-paragraph summaries of recent sessions | Last 10-15 at session start |
| memory/ topic files | Agent | Detailed memories on specific topics | On demand |

## Extraction strategy

Three tiers:

| Tier | Trigger | Example |
|------|---------|---------|
| **Explicit** | User says "remember X" or uses `/remember` | "Remember: I prefer tabs over spaces" |
| **Correction-driven** | User corrects same thing ≥2 times | "You used the wrong null check again — always use strict null checks" |
| **Implied** | Pattern observed 3+ times | User consistently uses pnpm, not npm — note with lower confidence |

The agent proposes PROFILE.md additions but never modifies the user's profile
without explicit confirmation.

## Memory commands

- `/remember <fact>` — explicitly store in memory
- `/memory` — show what's currently remembered
- `/forget <topic>` — remove a memory entry

## Loading priority

When context tokens are constrained:
1. PROFILE.md (sacred — always loaded)
2. MEMORY.md index (first 200 lines)
3. Recent session summaries (last 10-15)
4. Current conversation
5. Topic files (on demand)

## Design principles

- **Plain markdown** — transparent, user-editable, no databases
- **User control** — view, edit, delete at any time
- **Local only** — stored at `~/.pi/user/`, no cloud sync
- **Recency-based** — newer memories override older ones by default
- **Confidence scored** — explicit > correction-driven > implied

## See also

- [agent orchestration architecture](agent-orchestration-architecture.md)
- `orchestrator-guidance` skill — loads and uses the user model
- `wiki-maintenance` skill — extracts user signals after sessions
