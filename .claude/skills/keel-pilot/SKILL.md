---
name: keel-pilot
description: Staged bulk-run gate — before any mass-output job (labeling, generation, migration) enforce, in order, declare thresholds → smoke sample → gold-set validation → progressive ramp with halt conditions → acceptance sample. No full run on an unvalidated pipeline.
---

# /keel-pilot — never run a big batch blind

Use when a task will produce **many outputs whose quality cannot be eyeballed one by one** — mass
labeling/classification, bulk generation, large migrations/transforms (heuristic: >100 items, or any
unattended run). The failure this kills: pipelines verified "sometimes, by mood" — quality problems
discovered after 5,000 items, or never. The sequence below is the published norm, not an invention
(Anthropic best-practices fan-out, Pangakis et al. 2023, SRE canarying, Write-Audit-Publish);
evidence trail with sources: `research/*/findings.md` (2026-07-16).

Five gates, in order. **A gate must PASS before the next opens** — report each as pass/fail.

## Gate 0 — DECLARE (before anything runs)
Write into the task (`TASKS.md done-when:` or a short pilot plan next to the runner):
- **acceptance metrics** — e.g. per-class precision/recall vs a gold set; schema-validity %;
- **halt thresholds** for the full run — e.g. >5% schema-invalid, or error rate >2× the pilot's,
  in any rolling 100-item window → HALT;
- **sample plan** — smoke size (10–50) · gold set (250+ human-labeled items when label quality is
  load-bearing; smaller only with the user's explicit OK) · honeypot rate (5–10%) · acceptance
  sample by the rule of three (0 errors in 60 ⇒ <5% true error rate, in 300 ⇒ <1%, at 95%).
Thresholds chosen AFTER seeing outputs are not thresholds. Defaults above are the literature's —
adjust per project, with the user.

## Gate 1 — SMOKE (10–50 items)
Run the pipeline end-to-end on 10–50 representative items, edge cases included. Human eyeball +
mechanical schema check (fields present, types right, label ∈ allowed set). Any surprise → fix,
re-smoke. Never skip to Gate 3 because "the code looks right".

## Gate 2 — VALIDATE (against ground truth)
Run on the gold set; compare **per class** (aggregate accuracy hides minority-class failure —
median GPT-4 accuracy across 27 real tasks was 0.850 while a third of tasks had precision or recall
below 0.5). Agreement bar: Krippendorff **α ≥ 0.800** to rely on labels; 0.667–0.800 supports only
tentative conclusions. Below bar → revise prompt/config and re-run THIS gate. Record the passing
numbers in `reports/` (dated) — they are the baseline the circuit breaker compares against.

## Gate 3 — RAMP (staged full run)
- Scale **~1% → ~10% → 100%**, checking the declared metrics at each step before widening.
- Seed **honeypots** (gold items, 5–10%) into the live stream; score them as results arrive.
- Schema-validate **every record** as it is produced (cheap script, not an LLM).
- **Circuit breaker:** the declared halt thresholds are enforced by the runner script — a breach
  HALTS the run (dbt `error_if` semantics), it does not merely warn.
- **Checkpoint by stable id** so a halted run resumes without redoing finished work.
- Write to a **staging location** (Write-Audit-Publish) — never directly to the final table/dir.

## Gate 4 — ACCEPT (before publishing)
- Draw the acceptance sample (60 or 300 per the rule of three) and check it. For judgment calls,
  spawn the **verifier** subagent to adversarially refute a random subset — the agent that produced
  the batch does not grade it. If the grader is itself an LLM: swap positions / use several diverse
  votes (position and self-preference bias are documented).
- Route low-consistency or non-unanimous items to the **user** (human review) rather than guessing.
- All green → publish staging → final. Write the one-liner (counts, error bound, gate results) into
  HANDOVER (a), and add the pipeline's must-run check as a `LESSONS.md [test]` line.

## Scope honesty
- The gate **sequence** is ritual (this skill); the runner **mechanics** (schema validator, breaker,
  checkpointing, honeypot scoring) are a small per-project script under `src/`, written at Gate 0 if
  missing — prose cannot enforce a breaker, the script does.
- If the same bulk pipeline recurs, promote a project-specific PreToolUse gate (block the bulk
  entrypoint unless a fresh pilot report exists) — the §2.9 promotion rule applied to enforcement.
- Re-runs after a prompt/model/config change start again at Gate 2 ("LLM hacking": config choices
  alone flip conclusions). A pilot passed months ago is not a current pilot.
