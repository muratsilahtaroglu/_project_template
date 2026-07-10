# tests/ — organized test folder (rules.md §2)

- `unit/` — pure unit tests.
- `integration/` — tests against real dependencies (DB/services).
- `e2e/` — end-to-end smoke tests.
- `fixtures/` — saved input snapshots (no live requests in CI).

Relevant tests are written/run on every change; results are summarized in `HANDOVER.md`.
