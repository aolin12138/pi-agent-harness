---
title: "Available Tools"
type: reference
updated: 2026-05-31
sources:
  - Pi agent runtime (as observed in sessions)
tags: [tools, capabilities]
---

# Available Tools

Tools available to the Pi agent during sessions.

## Core tools

| Tool | Purpose |
|------|---------|
| `read` | Read file contents (text and images) |
| `bash` | Execute bash commands |
| `edit` | Precise file edits with exact text replacement |
| `write` | Create or overwrite files |
| `task_create` | Create a session task |
| `task_list` | List all session tasks |
| `task_get` | Get task details by ID |
| `task_update` | Update task status/fields |
| `task_batch` | Atomic batch task operations |

## Research tools

| Tool | Purpose |
|------|---------|
| `web_search` | Web search via Perplexity/Exa/Gemini |
| `code_search` | Code examples and API docs |
| `fetch_content` | Fetch URL content, YouTube transcripts, GitHub repos |

## Agent tools

| Tool | Purpose |
|------|---------|
| `subagent` | Launch subagent(s) from roster |
| `subagent_kill` | Stop running subagent |
| `subagent_resume` | Resume a previous subagent session |

## Interaction tools

| Tool | Purpose |
|------|---------|
| `ask_user` | Interactive user clarification |
| `run_workflow` | Run a named workflow |
| `run_prompt_autoresearch` | Iterative prompt optimization |
| `benchmark_prompt_autoresearch` | Benchmark prompt stability |

## See also

- [agent agents](../built/agent-agents.md)
- [skills](../built/skills.md)
