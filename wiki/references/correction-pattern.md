# Correction pattern

From LLM Wiki `references/quality.md`. When initial analysis was wrong,
document the correction explicitly rather than silently rewriting:

```markdown
### Correction: [what was wrong]

[Original claim] was incorrect because [reason].
The accurate picture is [correction].
```

This preserves the learning arc. Silent rewrites lose the pedagogical
value of the mistake — and break audit trails when someone (you, later)
wonders why the page changed.

## When to use

- A compiled page contains a factual error discovered later
- A decision was made based on incorrect assumptions
- An agent hallucinated a claim that was subsequently verified

## When NOT to use

- Minor typos or formatting fixes
- Routine updates (new `updated:` date, added source)
- Expanding a stub — just expand it
