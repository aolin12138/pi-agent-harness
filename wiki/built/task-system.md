---
title: "Task System"
type: concept
updated: 2026-05-31
sources:
  - ~/.pi/agent/sessions/--C--Users-User-.pi--/
tags: [tasks, tracking, session]
---

# Task System

Session-scoped task tracking system available as tools to the Pi agent.

## Tools

| Tool | Purpose |
|------|---------|
| `task_create` | Create one structured task |
| `task_list` | List all session tasks |
| `task_get` | Retrieve task by ID with full details |
| `task_update` | Update task status, subject, description, metadata, dependencies |
| `task_batch` | Atomic batch create/update/delete |

## Task lifecycle

```
pending → in_progress → completed
                       → deleted
```

Tasks support:
- Dependency tracking (blocks / blockedBy)
- Metadata (arbitrary KV)
- Active form (present continuous for in_progress display)
- Subject + description

## See also

- [agent agents](agent-agents.md)
- [workflows](workflows.md)
