---
name: update
description: Pull the latest Keel template improvements into THIS project — diff template-owned files, apply only user-approved hunks. Never touches project memory (HANDOVER/LESSONS/TASKS) or tailored docs.
---

# /update — sync this project with the latest Keel template

Use when the kit was **cloned** a while ago and the template has since improved (hardened hooks, doc
fixes, workflow updates). Pull model: run it IN the project, review diffs, approve. Non-destructive is
the hard rule (same spirit as `/adopt`): nothing is applied without a shown diff + an explicit yes.

**Plugin half first:** if the `keel` plugin is installed (skills show up as `/keel:*`), the tooling
(skills · agents · hooks) already updates centrally — run `/plugin marketplace update keel` for that
half and skip those paths below; this skill then only handles the doc half.

## 1. Fetch the latest template (never inside the project)
```bash
git clone --depth 1 https://github.com/muratsilahtaroglu/claude-code-starter-kit /tmp/keel-latest
git -C /tmp/keel-latest rev-parse --short HEAD   # record for the handover line
```

## 2. Classify every template path into three buckets
- **PROTECTED — never touched (project-owned):** `HANDOVER.md` · `LESSONS.md` · `TASKS.md` ·
  `docs/handover-archive.md` · `docs/architecture.md` · `docs/adr/*` (except the `0000` template) ·
  `CLAUDE.md` · `README.md` · `LICENSE` · `config/` · `requirements/*.{txt,lock}` contents ·
  `.env.example` values · `src/` · `tests/` · `research/` findings · `reports/`.
- **REVIEW — likely tailored; full diff, apply hunk-by-hunk with approval:** `rules.md` ·
  `.claude/settings.json` (permissions merge = union, keep the project's) · `.gitignore` ·
  `.pre-commit-config.yaml` · `Makefile` · `Dockerfile*` · `docker-compose.yml` ·
  `.github/workflows/*` · `docs/layouts.md` · `docs/user_manual.md`.
- **TOOLING — template-owned; summarize changes, one approval for the batch:** `.claude/skills/**` ·
  `.claude/hooks/**` · `.claude/agents/{researcher,verifier,README}.md` · `.claude/rules/README.md`
  (+ example) · `.claude-plugin/**` · `docs/security.md` · `docs/steering.md` ·
  `docs/adr/0000-adr-template.md` · folder `README.md`s.

**Respect the bootstrap prune (rules.md §0e):** files the tailoring removed on purpose (recorded in the
first HANDOVER block / tailoring ADR) are **not re-added** — list them as "pruned, skipped" unless the
user explicitly asks for them back.

## 3. Present the plan, then apply approved-only
One table — **new · changed · pruned-skipped · protected** — one line per file with what/why. Then the
diffs per §2 buckets. Apply only what was approved; never resolve a conflict silently.

## 4. Verify + record
- Hooks stay executable: `chmod +x .claude/hooks/*.sh`. If `.claude-plugin/` changed:
  `claude plugin validate <project-root>`.
- Quick smoke: the project's tests still pass (rules.md §2.8).
- `HANDOVER.md` block (a) one-liner: `keel /update applied @ <template-sha>: <files>`; structural
  changes also land in `docs/architecture.md` (rules.md §1.6). Commit with approval (rules.md §6).
