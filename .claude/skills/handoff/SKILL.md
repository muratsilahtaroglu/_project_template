---
name: handoff
description: Update HANDOVER.md before ending a session or compacting — record done / tried-failed / latest / next.
disable-model-invocation: true
---

# /handoff — update the session handover

Update `HANDOVER.md` at the repo root (rules.md §1.4). Cumulative and historical: append, don't
overwrite past entries.

Steps:
1. Read the current `HANDOVER.md`.
2. Fill each section from THIS session:
   - **(a) Completed work** — what was done, dated; link decisions to their ADR/docs.
   - **(b) Tried, didn't work** — approaches that failed + the reason, so they aren't retried. This is
     the highest-value section — don't skip it.
   - **(c) Latest updates** — the most recent concrete changes.
   - **(d) Next steps** — prioritized, for the next session.
   - **Open questions** — anything awaiting a user decision.
3. Set the `_Last updated:_` line to today's date + a one-line status.
4. Do NOT commit/push without user approval (rules.md §1.3, §6.15).
