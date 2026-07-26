---
name: shared-language
description: >
  Project domain glossary and shared vocabulary. Use when starting work on an
  unfamiliar project or codebase, when terminology is inconsistent, or when
  building a CONTEXT.md to help agents navigate the codebase efficiently.
---

# Shared Language

A framework for building and maintaining a domain glossary that gives all
agents a precise, consistent vocabulary for the project they're working on.

## The problem this solves

Agents dropped into an unfamiliar project describe concepts in long-winded
ways because they don't know the project's terminology. This wastes tokens,
produces inconsistent naming, and makes code harder to navigate:

- Without glossary: "There's a problem when a lesson inside a section of
  a course is assigned a real location in the file system"
- With glossary: "There's a problem with the materialization cascade"

The difference compounds across sessions. A shared language pays for itself
within a few interactions.

## The CONTEXT.md file

A `CONTEXT.md` at the project root is the domain glossary. It contains
nothing but definitions of domain terms. It is NOT a spec, NOT a scratch
pad, NOT a repository for implementation decisions. It is a dictionary.

### Format

```markdown
# Domain Glossary

## Term 1
Precise, concise definition. What it means in this project's domain.
Distinguish from similar terms if ambiguity exists.

## Term 2
Definition. Include constraints, invariants, or lifecycle if relevant.
```

### Principles

- **Lazy creation.** Don't create CONTEXT.md until the first term needs
  defining. Don't pre-populate with guesses.
- **Add terms as they crystallize.** When a concept is named during
  requirements discussion, planning, or review, add it immediately.
- **Precision over completeness.** A glossary with 5 razor-sharp terms is
  better than one with 20 fuzzy ones.
- **No implementation details.** "Order" belongs in the glossary. "The
  OrderTable component uses a reducer pattern" does not.
- **Challenge drift.** If someone uses a term inconsistently with the
  glossary, flag it: "The glossary defines X as Y, but you seem to
  mean Z — which is it?"

### Multi-context projects

For monorepos or projects with distinct subsystems, a `CONTEXT-MAP.md`
at the root points to context-specific glossaries:

```
/
├── CONTEXT-MAP.md          ← maps subsystem to its glossary
├── src/
│   ├── ordering/
│   │   └── CONTEXT.md      ← ordering domain terms
│   └── billing/
│       └── CONTEXT.md      ← billing domain terms
```

Create lazily — only when a subsystem needs its own vocabulary.

## How agents use it

### During understanding (scout, grill-me)

Read CONTEXT.md first to orient. When the user uses a term, check it
against the glossary. If the term is missing but important, propose
adding it. If the term conflicts, flag it.

### During planning (planner)

Use glossary terms in the plan. Module names, function names, and
variable names should derive from the domain language. A plan that
invents new names for existing concepts is a plan that doesn't
understand the domain.

### During execution (executor)

Name things using glossary terms. Consistent naming makes the codebase
navigable — for humans and for future agent sessions.

### During verification (reviewer)

Check that new code uses the domain language consistently. Flag
inconsistencies: "This module is named 'PurchaseHandler' but the
glossary defines this concept as 'Order'."

## Integration with the orchestrator

The orchestrator ensures CONTEXT.md is:

1. **Read** during the Understanding phase — scouts and grill-me reference it
2. **Updated** when new terms are resolved — typically during requirement
   clarification or after architectural decisions
3. **Enforced** during review — the reviewer checks naming consistency

A project without CONTEXT.md is not broken — it just lacks a shared
language. The orchestrator should propose creating one when domain
confusion appears (the same concept described three different ways).

## Relationship to the wiki

CONTEXT.md is project-level (lives in the project repo). The wiki is
meta-level (lives in `~/.pi/llm-wiki/`). They serve different purposes:

| | CONTEXT.md | Wiki |
|---|---|---|
| **Scope** | One project's domain | Cross-project knowledge |
| **Content** | Domain terms only | Architecture, decisions, status, history |
| **Audience** | All agents working on this project | Pi orchestrator |
| **Lifecycle** | Grows with the project | Grows with the pi ecosystem |

A CONTEXT.md can be referenced from the wiki (e.g., "see the project's
CONTEXT.md for domain terminology"), but it lives with the project.

## When this skill applies

Use this skill when:
- Starting work on a project with non-trivial domain concepts
- The agent is using verbose descriptions where a short term would do
- Naming inconsistencies appear across sessions
- The orchestrator wants to reduce token usage over multiple sessions

Skip it when:
- The project is trivially simple (no domain worth modeling)
- The work is a one-off task with no future sessions
- The project already has excellent documentation that serves the same purpose

## Related frameworks

- `grill-me-requirements` — domain terms are often crystallized during
  requirement clarification
- `orchestrator-guidance` — the orchestrator manages CONTEXT.md lifecycle
- `verification-protocol` — naming consistency is a quality dimension
