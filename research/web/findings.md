# web/ findings — official docs, SRE runbooks & industry QA guides (2026-07-16)

> Question: what do official Claude Code docs and industry runbooks prescribe for staged/verified
> batch runs, and which NATIVE mechanisms can enforce it. Feeds the pilot-gate design
> (candidate v0.8.2). Distilled per rules.md §8.

## Synthesis
Claude Code's own best-practices page prescribes exactly the ladder we need — in-prompt check →
`/goal` per-turn evaluator → **Stop-hook deterministic gate (exit 2)** → fresh-context
verification subagent — plus pilot-then-scale fan-out for bulk jobs. SRE canarying,
Write-Audit-Publish and acceptance sampling supply the numbers and the staging pattern. What no
source supplies is the enforcement RITUAL — that is the kit's slot.

## Findings (claim | source | confidence | note)
- Official verification ladder: "give Claude a check it can run"; Stop hook exit-2 gate
  (auto-overridden after 8 consecutive blocks); verification subagent that "tries to refute the
  result, so the agent doing the work isn't the one grading it" |
  https://code.claude.com/docs/en/best-practices | high | canonical, fetched in full.
- Official fan-out for bulk jobs: "test on a few files, then run at scale"; refine the prompt on
  the first 2-3 failures | same URL | high | = the user's exact "5000 tweets" scenario.
- Hooks mechanics: **exit 2 = blocking** (event-dependent), **exit 1 = non-blocking** (classic
  silent-pass gotcha); PostToolUse cannot undo the tool but its stderr IS fed back to Claude;
  Stop + exit 2 prevents stopping | https://code.claude.com/docs/en/hooks | high.
- Native capability map for pilot→verify→batch→monitor: PreToolUse gates by script/command
  pattern; **Monitor tool = the only native line-by-line output watcher**; `run_in_background`
  notifies on completion (no mid-run interrupt); subagents can verify but cannot halt the parent;
  permissions are too coarse for semantic gating |
  https://code.claude.com/docs/en/tools-reference.md ·
  https://code.claude.com/docs/en/sub-agents.md ·
  https://code.claude.com/docs/en/hooks-guide.md | high | guide-agent survey, spot-checked.
- Experimental "observer agents" (env-gated, v2.1.207+): read-only digest, ONE advisory message,
  **cannot halt/pause/veto**; absent from official docs |
  https://claudefa.st/blog/guide/agents/observer-agents | medium | third-party writeup of an
  undocumented feature — do NOT build on it.
- Ralph loop pattern (community): `while` loop around `claude -p`; guards = tests as
  backpressure, one task per loop, spec files; known failures = placeholder implementations;
  recovery = `git reset` | https://ghuntley.com/ralph | high | pattern essay, widely referenced.
- The "Hermes watchdog" phrase = community blog describing a **cron job that restarts the crashed
  Hermes gateway process** — uptime supervision, not output QA |
  https://buttondown.com/witcheer/archive/mac-mini-24-7/ | high | primary source of the phrase.
- Hermes official docs: security = command approval / DM pairing / container isolation; no
  verification watchdog | https://hermes-agent.nousresearch.com/docs/ | high.
- SRE canarying: expose to a small population first, widen progressively, **auto-halt when the
  canary error metric diverges from control** | https://sre.google/workbook/canarying-releases/ |
  high | the 1%→10%→100% split is convention, not prescribed — FLAG.
- Anthropic Batch API: "verify your request shape with the Messages API first"; per-request
  terminal states (succeeded/errored/canceled/expired); results unordered — match by custom_id |
  https://platform.claude.com/docs/en/docs/build-with-claude/batch-processing | high | retry &
  resume are per-request, which is what makes checkpointing workable.
- OpenAI batch cookbook: try requests on the sync endpoint first; results unordered | 
  https://developers.openai.com/cookbook/examples/batch_processing | high | honest negative:
  API docs do NOT supply QA methodology — the discipline must come from elsewhere.
- Krippendorff α thresholds: **α ≥ 0.800 reliable; 0.667–0.800 tentative conclusions only** |
  https://www.asc.upenn.edu/sites/default/files/2021-03/Computing%20Krippendorff's%20Alpha-Reliability.pdf |
  high | the author's own canonical guidance; applies to LLM-vs-human agreement.
- Honeypots/gold items seeded into live batches at **5–10% coverage**; per-job quality scored
  from honeypot accuracy | https://www.cvat.ai/resources/blog/annotation-qa-honeypots | high |
  vendor doc but concrete.
- Pilot sizing **100–200 items or 5–10%** of dataset (industry labeling guides) |
  https://www.taskmonk.ai/blogs/guide-to-data-labeling-quality ·
  https://labelyourdata.com/articles/data-annotation/quality-assurance | medium | search-summary
  figures — FLAG.
- **Rule of three**: 0 errors in n sampled outputs ⇒ true error rate < 3/n at 95% confidence
  (spot-check 60 ⇒ <5%; 300 ⇒ <1%) |
  https://www.statology.org/a-concise-guide-to-the-statistical-rule-of-three/ ·
  https://asq.org/quality-progress/articles/back-to-basics-zero-defect-sampling?id=1f11b12f0dd74b3887336e7ad907c561 | high.
- dbt `severity`/`warn_if`/`error_if` = the citable error-rate circuit breaker (e.g.
  `error_if: ">10"` halts; failed upstream test skips downstream models) |
  https://docs.getdbt.com/reference/resource-configs/severity | high.
- Great Expectations checkpoints gate pipelines on validation results |
  https://docs.greatexpectations.io/docs/0.18/reference/learn/terms/checkpoint/ | medium-high.
- Write-Audit-Publish (Netflix-origin): write batch outputs to a STAGING location → audit there →
  publish only on pass | https://lakefs.io/blog/data-engineering-patterns-write-audit-publish/ ·
  https://aws.amazon.com/blogs/big-data/build-write-audit-publish-pattern-with-apache-iceberg-branching-and-aws-glue-data-quality/ | high.
- AWS Augmented AI human-loop triggers: below-confidence routing + random-sample audit — the
  industry-standard two human gates |
  https://docs.aws.amazon.com/sagemaker/latest/dg/a2i-use-augmented-ai-a2i-human-review-loops.html | high.

## Takeaway for Keel
Everything needed exists natively (PreToolUse gate + verifier subagent + Monitor + Stop hook).
What is missing in every source is the non-optional RITUAL — a pilot gate with pre-declared
thresholds. That is precisely the kind of gap Keel exists to fill.
