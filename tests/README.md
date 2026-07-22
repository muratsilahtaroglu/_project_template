# tests/ — organized test folder (rules.md §2)

- `unit/` — pure unit tests.
- `integration/` — tests against real dependencies (DB/services).
- `e2e/` — end-to-end smoke tests.
- `fixtures/` — saved inputs and reusable case sets as DATA (no live requests in CI). Any format that
  fits the test — `.json` / `.jsonl` / `.yaml` / `.parquet` / `.html` / …

**Two kinds of cases — different rules.** Ordinary unit-test edge cases belong INLINE in the test code
(pytest parametrize is idiomatic; readable diffs beat indirection). But a **corpus** — any case set that
is run repeatedly across phases/models/configs (golden question sets, SQL goldens, honesty/regression
sets, `/keel-pilot` gold sets) — is DATA with **stable ids**, never buried in test code or chat history.
Default home: `fixtures/`. A dedicated corpus dir (e.g. `benchmarks/`) is fine — **then this README
carries a one-line corpus index pointing to it**, so `tests/` remains the one place to find every case
set. §10.39's failing-case rule feeds these corpora: every point-fixed failure joins one.

**Why-READMEs (per folder).** Each subfolder's `README.md` lists every test/fixture file with ONE
line — what it guards and why it exists (the phase/bug that produced it) — added the moment the file
is added. Months later, "why did we even write this test?" must have an answer.

**Results — every run leaves a dated trace.**
- `make test` auto-logs each run (pass AND fail) to `reports/tests/<YYYY-MM-DD>/<HHMMSS>-pytest.log`,
  stamped with commit + branch. Raw logs are git-ignored — a local "what ran when" history. Direct
  `pytest` calls don't log; run through `make test`.
- Phase ends get a **committed** summary — `reports/tests/<YYYY-MM-DD>-phase<N>.md`, written at
  `/keel-phase-review`: suites run, pass/fail counts, what was verified. The durable, greppable
  record of which tests backed which phase.
- The handover still carries the one-line summary (rules.md §2.8); critical outcomes (a must-run
  test, a recurring failure) are distilled into `LESSONS.md` `[test]`/`[fail]` — logs are the raw
  archive, LESSONS is the knowledge.
