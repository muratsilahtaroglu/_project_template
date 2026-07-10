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
