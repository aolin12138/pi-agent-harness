# Source template

Adapted from LLM Wiki `references/source.template.md`.

Use this when copying a source verbatim into `raw-sources/<bucket>/`.
For sources that already exist at a stable path (in-repo files, URLs,
session JSONL), reference them in `raw-sources/index.md` instead of
copying.

## Template

```markdown
---
title: <descriptive title>
url: <canonical URL if any, omit for pasted conversations>
collected: YYYY-MM-DD
published: YYYY-MM-DD
authors: []
tags: []
reliability: high | mixed | unverified
---

# <Source Title>

<!-- Verbatim content below. Do not rewrite or summarize. -->
```

## When to copy vs reference

| Source type | Action |
|-------------|--------|
| Pi session JSONL | Reference in `raw-sources/index.md` (stable path) |
| In-repo file | Reference by path (stable, version-controlled) |
| Public URL | Reference by URL (may rot — consider archiving) |
| Auth-walled (Google Doc, Confluence) | Copy into `raw-sources/external/` |
| Pasted conversation | Copy into `raw-sources/conversations/` |
| CodeGraph snapshot | Reference in `raw-sources/codegraph/` |

## See also

- LLM Wiki `references/source.template.md` — canonical template
- `raw-sources/index.md` — source registry
