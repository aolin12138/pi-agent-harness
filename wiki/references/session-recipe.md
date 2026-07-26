# Session extraction recipe

For Pi agent session extraction, use the LLM Wiki `references/pi-session-recipe.md`
as the canonical recipe. It covers:

- Directory layout (`~/.pi/agent/sessions/--<encoded-cwd>--/`)
- Fork detection (parents with >1 child)
- Content extraction with `jq`
- Subagent session detection (via `parentSession` header field)
- Multi-session synthesis

## .pi-specific additions

### Python alternative (Windows-compatible)

The LLM Wiki recipe uses `jq` (Unix-native). For Windows, our
`wiki-maintenance` skill provides a Python equivalent at
`~/.pi/agent/skills/wiki-maintenance/SKILL.md` §2.

### Subagent identification

Subagent sessions have `parentSession` in their JSONL header. The
LLM Wiki recipe's fork detection covers this. Additionally, check
for `pi-subagents_launch_metadata` custom entries for agent name
and launch parameters.

## See also

- LLM Wiki `references/pi-session-recipe.md` — canonical bash/jq recipe
- `wiki-maintenance` skill §2 — Python alternative
