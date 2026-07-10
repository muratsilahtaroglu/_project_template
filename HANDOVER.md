# HANDOVER.md — Cumulative session handoff (TEMPLATE)

> Updated BEFORE every compact/session end. Cumulative and historical. Purpose: on long projects (even
> after many compactions), every step is recorded so progress stays stable across sessions.
> (This is the widely-used "handover file" pattern: the repo is durable disk, the context window is
> volatile RAM — anything not written here is assumed lost.)

_Last updated: <YYYY-MM-DD> — <short status>._

---

## (a) Completed work
- <YYYY-MM-DD> — <what was done, briefly>. (Details/decisions → relevant ADR / docs.)

## (b) Tried, didn't work (don't retry)
- <approach> — TRIED, FAILED, reason: <...>. (So it isn't tried again — the highest-value section.)

## (c) Latest updates
- <most recent changes>

## (d) Next steps
- <what to do next session, in priority order>

## Open questions / pending user decisions
- <topics awaiting a decision>

---

## Scaling: per-area handovers (optional)
**Default: this single root file.** On a **large, multi-area** project (e.g. backend + frontend +
agent/LLM) it can grow noisy — then, when an area is developed in its own sessions, give it a
**per-area handover** next to its code (`backend/HANDOVER.md`, `frontend/HANDOVER.md`,
`agents/HANDOVER.md`), each with its own (a)–(d). In that setup:
- this **root** file becomes the **program-level index**: milestones, cross-area/integration decisions,
  and the links below. **One "latest" per area — no duplicated truth.**
- pair each with a nested **`<area>/CLAUDE.md`** that `@`-imports its `<area>/HANDOVER.md`; Claude Code
  auto-loads a subtree's `CLAUDE.md` when working there, so the right memory comes in automatically.
- **the AI creates a per-area handover when an area starts needing its own**, and **MUST register the
  structure in `docs/architecture.md`** (+ wire the nested `CLAUDE.md` `@`-import). Start with one file;
  split only when it hurts.

### Area handovers (index)
- <area> → `<area>/HANDOVER.md` — <one-line status>  <!-- add rows only when you actually split -->

