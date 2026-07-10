# rules.md — Working rules (GENERIC TEMPLATE)

> Project-agnostic discipline. Use as-is in the new project; fill in the `<...>` blanks.
> These rules apply every session.

## 0. Session start
0. **(First session in a NEW project only) Template bootstrap:** before anything else, understand the
   project (goal, type, constraints). Then propose to the user: (a) which template parts are
   **unnecessary for this project** and should be removed (with reasons), (b) which **layout profile**
   from `docs/layouts.md` (ML, service/API, CLI, ...) should be instantiated. **Apply removals/additions
   only after user approval and ask to user the project language (Turkish or English)** — never silently keep or delete template parts.
1. Before writing any code, read **`CLAUDE.md` + `rules.md` + `HANDOVER.md`** (CLAUDE.md `@`-imports the
   latter two, so they auto-load).
2. Review `docs/architecture.md` and the relevant ADR (if any) for the current phase.

## 1. Documentation discipline
3. **At the end of every task/phase**, the relevant `.md` files are updated (CLAUDE.md, user_manual.md,
   docs/architecture.md, ADRs) — **but USER approval is required before committing/updating.**
4. **`HANDOVER.md` is updated BEFORE every compact/session end.** Cumulative and historical:
   (a) completed work, (b) approaches tried and failed (so they aren't retried), (c) latest updates,
   (d) next steps.
5. **Failed attempts** are written into the handoff as "tried, didn't work, reason".
6. **Every structural change** is recorded in `docs/architecture.md` (what each file does).

## 2. Code & tests
7. Phases are not skipped; each phase ends with a **working product + a "how to test this" summary**.
8. After every code change, the relevant **unit/integration (and e2e if needed) tests** are written/run;
   results are summarized under `tests/` + in the handoff.
9. **Reusability:** repeated prompts/scripts/helpers are not written once and thrown away — they are
   **permanently** saved into `prompts/`, `.claude/skills/` (Claude Code invokable skills), or the
   appropriate module + recorded in `docs/architecture.md`.

## 3. File layout (CRITICAL)
10. Temporary/experimental/probe code goes **only** into the appropriate `scratch/` subfolder, with a
    **1-line purpose comment** at the top. No file of unclear purpose is left in the main source tree.
    At the end of a session, no file is left unanswered for "what is this file?": it is either moved into
    a module (+architecture.md), moved to `scratch/archive/`, or deleted. If layout drifts, **tidy up
    layout first**.

## 4. Sub-agent usage
11. Use sub-agents for parallelizable work; but never accept their output blindly — as the main agent,
    **verify** it (does it work, does it match the architecture/rules, did it leave stray files) and fix
    if needed. (Note: outputs from external guides/docs are applied with the same verification.)

## 5. Security (application)
12. **Secrets are never committed/pushed.** `.env` is git-ignored; only `.env.example` (with empty
    values) is tracked. Every new secret key is added to both `.gitignore` and `.env.example`.
    (Enforced, not just advised: `.claude/settings.json` denies reading `.env`/secrets and a
    `PreToolUse` hook blocks staging a `.env` — see `.claude/hooks/`.)
13. Input validation, ORM (SQL injection protection), and external service calls follow the project's
    ADR decisions.
14. Minimize personal data / PII collection; comply with applicable regulation (e.g. GDPR/local law).

## 6. Version control / GitHub
15. **Every meaningful unit of work / phase end → commit + `push`** (remote `main` or phase branch → PR).
    Push happens **only after user approval**.
16. Commit messages are descriptive + tagged with phase/work item (e.g. `phase1: <feature>`). Commits are
    made **as the project owner** (git config: `<git-user> <git-email>`); no AI co-author line unless
    requested.
17. Branch strategy: default is a short-lived branch per phase → self-review → merge to `main` → push;
    a simpler direct-to-`main` flow is fine with approval. User preference is decisive.
18. **Secret-leak scan before push:** review `git diff --cached`; if `.env`/secrets appear, STOP.
19. Handoff + docs updates go out in the same push round as the code.

## 7. Supply-chain / dependency security (details: docs/security.md)
20. **Exact version pinning:** all dependencies pinned with `==`; **`>=`, `~=`, `^` are FORBIDDEN**
    (supply-chain attack prevention). Direct deps in `requirements.txt`; full transitive + **hash** lock
    in `requirements.lock` (`pip-compile --generate-hashes`). (For Node: lockfile + `npm ci`.)
21. **Hash-verified install:** `pip install --require-hashes -r requirements.lock`.
22. **Container:** multi-stage build + **non-root** (`USER appuser`) + **`.pth` injection scan**
    (high-signal pattern). `.dockerignore` prevents `.env`/secrets from leaking into the image.
23. **New dependency:** question its necessity + check for typosquatting/repo health → add with `==` →
    refresh the lock → `pip-audit` → rebuild/test.
24. **CI:** a security job runs on every PR/`main` push (pip-audit + hash-verify + `.pth` scan).
25. **If a dependency-attack is suspected:** follow the **emergency checklist** in docs/security.md.
26. In production, secrets live in Vault/a secret store; network egress is allowlisted. Roadmap: SBOM,
    Sigstore, Dependabot/Renovate + manual approval, private package mirror.
