# CLAUDE.md — <PROJECT NAME> project constitution (TEMPLATE)

> Claude Code reads this first every session. The two `@`-imports below auto-load the working rules and
> the running handover, so they're always in context. Keep this file lean (< ~200 lines); push
> sometimes-relevant knowledge into `.claude/skills/` and deterministic checks into `.claude/hooks/`.
> Fill in the `<...>` blanks.

@rules.md
@HANDOVER.md

## What we're building
<Purpose of the project in 2-3 sentences. What problem it solves, who uses it.>

## Architecture (summary)
<Components and how they talk to each other. E.g.: API (FastAPI) + Worker + DB + Vector DB + LLM. A text diagram.>

## Key decisions (ADRs in `docs/adr/`)
- <ADR-0001: ...>
- <ADR-0002: ...>
(Every significant technical decision becomes an ADR; copy `docs/adr/0000-adr-template.md`.)

## Stack & versions
<Languages, frameworks, libraries — with exact versions (rules.md §7: pinning).>

## Configuration
NO hard-coding. Secrets + machine-local values come from `.env` (key list: `.env.example`); non-secret
parameters from `config/<env>.yaml` selected by `ENV` (see `config/README.md`).

## Commands
```bash
<setup / run / test / migration commands — also wired into the Makefile>
```

## Conventions
- Reusable prompts live in `prompts/` (versioned; code never embeds prompt strings).
- Reusable Claude Code workflows live in `.claude/skills/<name>/SKILL.md` (e.g. `/handoff`, `/phase-review`).
- Throwaway/experimental code only in `scratch/<subfolder>/`, with a 1-line purpose comment at the top.
- Every structural change → `docs/architecture.md`. Every phase end → docs + HANDOVER.md (approved commit+push).
- Tests live in `tests/{unit,integration,e2e,fixtures}/`. Detailed rules: `rules.md`.
- Enforcement lives in `.claude/`: `settings.json` permissions + `hooks/` (block dangerous/secret commands,
  handover reminder). Rules are guidance; hooks/permissions are enforced.

## Directory map
See `docs/architecture.md` (live module map).
