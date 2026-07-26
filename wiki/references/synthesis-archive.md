# Synthesis and archive pages

Adapted from LLM Wiki `references/synthesis-and-archive.md`.

## Two derived-knowledge types

| Type | When | Cascade-updates? |
|------|------|:---:|
| `synthesis` | Connects ≥2 wiki pages with a new conclusion | Yes |
| `archive` | Point-in-time snapshot of a query answer | No — frozen |

## Filing procedure

1. Create a new page — never merge into existing concept pages
2. Place in the most relevant topic directory
3. `sources:` lists the wiki pages cited (not raw sources)
4. `index.md`: prefix summary with `[Synthesis]` or `[Archive]`
5. `log.md`: append `## [YYYY-MM-DD] archive | <page title>`

## When to use which

- **`concept`** — the topic is real, distilled from sources
- **`synthesis`** — the *connection* is the contribution; underlying
  concepts already have their own pages
- **`archive`** — a transcript of one reasoning event; frozen

## See also

- LLM Wiki `references/synthesis-and-archive.md` — canonical rules
- `SCHEMA.md` — page types
