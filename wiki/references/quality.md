# Quality rules

Extends the LLM Wiki `references/quality.md`. That document is canonical
for depth minimums, source reliability, concept variants, and the done
checklist. This file adds `.pi`-specific rules.

## .pi-specific additions

### Code reference rule

Wiki pages MUST reference code by file path, not embed large code blocks.
Example: `C:/Users/User/.pi/pi-web/src/components/SessionSidebar.tsx:179`
not a 50-line paste of the function.

### Session citation rule

When citing a Pi session, use the session file path (not the session ID):
`~/.pi/agent/sessions/--C--Users-User-.pi--/2026-05-31T10-09-42-027Z_....jsonl`

### Multi-project awareness

Pages in `projects/<name>/` should note when they depend on or interact
with other projects. Example: pi-web pages should mention the extension
server lives at `pi-web/extensions/server.ts` not in the Preact app.

## See also

- LLM Wiki `references/quality.md` — canonical depth minimums, reliability tiers, concept variants, done checklist
- `references/correction-pattern.md` — how to document corrections
- `references/source-template.md` — template for copied sources
