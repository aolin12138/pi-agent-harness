---
title: "Session Directory Layout"
type: reference
updated: 2026-05-31
sources:
  - ~/.pi/agent/sessions/
tags: [sessions, jsonl, storage]
---

# Session Directory Layout

Pi stores sessions as JSONL files in `~/.pi/agent/sessions/`.

## Directory naming

Each project gets a directory: `--<encoded-cwd>--` where `<encoded-cwd>` is the absolute working directory with path separators replaced by `-`.

## Projects with sessions

| Directory | Project | Sessions |
|-----------|---------|----------|
| `--C--Users-User--` | Home dir | ~19 sessions (Apr 22–23) |
| `--C--Users-User-.pi--` | .pi config | ~74 sessions (Apr 27–May 31) |
| `--C--Users-User-Archon--` | Archon | ~2 sessions (Apr 22) |
| `--C--Users-User-pi-mono--` | pi-mono | ~2 sessions (Apr 22) |
| `--E--OneDrive...-Mockly--` | Mockly | ~2 sessions (Apr 22) |

## JSONL event types

| Type | Description |
|------|-------------|
| `session` | Session metadata (version, id, timestamp, cwd) |
| `model_change` | Model/provider switch |
| `thinking_level_change` | Thinking level toggle |
| `message` | User or assistant message (may be forked via parentId) |
| `custom` | Tool execution events |
| `custom_message` | System reminders, subagent roster injection |

## Session recipe

See the pi-session-recipe for traversal patterns (fork detection, content extraction, failure analysis).

## See also

- [overview](overview.md)
- [architecture](architecture.md)
