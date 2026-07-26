---
name: wiki-audit
description: |
  Wiki health auditing for the LLM Wiki. Checks link integrity,
  index/filesystem sync, stub aging, contradictions, orphans, and
  pre-commit review of staged changes. Trigger on "audit wiki",
  "wiki health", "lint wiki", "review wiki changes", or before
  git commits to any llm-wiki repository.
---

# Wiki Audit

Audits LLM Wiki repositories for health and consistency. Used by the
reviewer agent before git commits and on a 4-day cycle. Defers to the
base LLM Wiki skill's Lint section for canonical rules.

## Pre-audit

1. `cd <wiki-root>` and `git status` — what's staged, modified, untracked?
2. Read `SCHEMA.md` and `index.md` for context.
3. Read `log.md` to see what changed since last audit.

## Audit checklist

### A. Git review (pre-commit)

For every staged or modified file:

- [ ] Does `log.md` have an entry for this change?
- [ ] Does the change match what `log.md` claims?
- [ ] Are new pages listed in `index.md`?
- [ ] Are deleted pages removed from `index.md` (marked `[MISSING]`, not deleted)?
- [ ] Commit message follows format: `[YYYY-MM-DD] <verb>: <what> — <why>`

### B. Link integrity (deterministic)

Run the base skill's deterministic lint checks:

- [ ] Every `](path.md)` resolves from the file's directory
- [ ] Every `](#anchor)` matches a heading in the target
- [ ] Every link into `raw-sources/` resolves
- [ ] `index.md` lists every `.md` file; no dead entries
- [ ] The **local** wiki index is canonical: any parent/central index holds
      only a one-row pointer per project (name, status, link to local index),
      never per-page summaries. Duplicated browse lists drift — flag and slim.

Auto-fix what you can. Report what you can't.

### B2. Ground truth (fact verification) — the checks that catch real drift

Structural checks (§B) catch broken plumbing; this section catches **wrong
content**. Added 2026-07-07 after an audit passed all structural checks while
the wiki claimed "18 scenarios" against 27 actual files.

- [ ] **Quantitative claims:** for every count, version, or model name in a
      page, verify against the source it cites. Counts are one command away:
      `ls <dir>/*.json | wc -l`, `grep -c`, `git log --oneline | wc -l`.
      Prioritize claims in `status.md` and architecture pages — they mislead
      future sessions the most.
- [ ] **`updated:` vs git:** cross-check frontmatter `updated:` against
      `git log -1 --format=%cs -- <file>`. A file whose git date is newer
      than its `updated:` was edited without a date bump — silent drift.
- [ ] **Post-merge staleness sweep:** list files changed since the last
      `log.md` entry (`git diff --stat <last-audit-ref>..HEAD -- . ':!<wiki-dir>'`)
      and check whether any wiki page's `sources:` cite those paths. Cited +
      changed + not recompiled ⇒ flag as stale with a ⚠ marker in the local
      index. This is the check that fires *when the repo is most active* —
      exactly when wikis decay fastest.
- [ ] **Lifecycle words:** grep pages for "planned", "WIP", "pending",
      "not yet" — verify each is still true. "Planned" features that shipped
      are the most common contradiction class.

### C. Structural health (heuristic)

- [ ] Stubs older than 30 days flagged
- [ ] Orphan pages (zero inbound links) noted
- [ ] Concepts mentioned ≥3× across wiki without a dedicated page
- [ ] Contradictions across pages without attribution
- [ ] Mixed/unverified sources cited without `## Source reliability` section
- [ ] See Also bidirectionality: A→B implies B→A

### D. Content quality (sample-based)

Pick 3 random pages and verify:

- [ ] Frontmatter: `title`, `type`, `updated`, `sources` present
- [ ] Body meets depth minimum for its type:
  - `concept` → ≥1 table, ≥1 code block, ≥3 paragraphs
  - `decision` → alternatives-considered table, ≥3 paragraphs
  - `bug`/`bugfix` → before/after code snippet, impact, regression test ref
  - `reference` → lookup table or command list (can be terse)
  - `stub` → frontmatter + one-paragraph rationale + link to raw source
- [ ] Claims cite sources; no uncited assertions
- [ ] `mixed`/`unverified` sources have `## Source reliability` section
- [ ] `## See also` present with 2–4 links
- [ ] Corrections use explicit pattern: `### Correction: [what was wrong]`
  rather than silent rewrites

If a sampled page fails, expand the sample to 6 pages.

### E. Done checklist (before marking a page complete)

Verify every new or updated page:

- [ ] Frontmatter: `title`, `type`, `updated`, `sources` present
- [ ] Body: one-paragraph hook + key claims (cited) + open questions
- [ ] Depth passes type minimums (see §D above)
- [ ] See Also: bidirectional links to related pages
- [ ] Index: page appears in `index.md` with one-line summary
- [ ] Log: entry appended to `log.md`
- [ ] For `mixed`/`unverified` sources: `## Source reliability` section present

## Audit report format

After audit, produce:

```markdown
## Audit Report — [YYYY-MM-DD]

### Git status
- Staged: <N> files
- Modified (unstaged): <N> files
- Untracked: <N> files

### Issues found
| Severity | Count | Description |
|----------|-------|-------------|
| BLOCKER  | N     | <what must be fixed before commit> |
| WARNING  | N     | <should be fixed, doesn't block commit> |
| INFO     | N     | <noted for awareness> |

### Blocker details
- <file>: <issue> — <fix applied or needs manual>

### Recommendations
- <actionable suggestion>

### Verdict
✅ APPROVED — ready to commit
⚠️ CONDITIONAL — commit after fixing <N> blockers
❌ REJECTED — <reason>
```

## Post-audit

1. Append to `log.md`: `## [YYYY-MM-DD] lint | <N> issues, <M> auto-fixed`
2. If `VERDICT: APPROVED`, the agent may `git commit` with the staged message
3. If `CONDITIONAL`, fix blockers and re-audit
4. If `REJECTED`, report to user with explanation

## Git commit template

```
[YYYY-MM-DD] <verb>: <what> — <why>

Changes:
- <file>: <summary>
- <file>: <summary>

Audit: ✅ approved (<N> issues, <M> auto-fixed)
```

## See also

- LLM Wiki SKILL.md — Lint section (canonical rules)
- `~/.pi/llm-wiki/references/quality.md` — .pi quality rules + depth minimums
- `~/.pi/llm-wiki/references/correction-pattern.md` — how to document corrections
- wiki-maintenance skill — ingest/update/research workflows
