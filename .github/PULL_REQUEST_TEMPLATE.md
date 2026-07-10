# <phase/work item>: <short title>

## What & why
<What this change does and the reason. Link the ADR if a decision was made.>

## How to test
<Commands / steps to verify — see rules.md §2.7.>

## Definition of Done (rules.md)
- [ ] Working product; "how to test this" included (§2.7)
- [ ] Relevant tests written & run; results in `HANDOVER.md` (§2.8)
- [ ] `docs/architecture.md` updated for any structural change (§1.6)
- [ ] ADR added in `docs/adr/` if a significant decision was made
- [ ] `CLAUDE.md` / `docs/user_manual.md` updated if behavior/usage changed (§1.3)
- [ ] `HANDOVER.md` updated (§1.4)
- [ ] `git diff --cached` reviewed — no `.env`/secrets staged (§6.18)
- [ ] Deps changed? lock refreshed + `pip-audit` clean (§7.23)
