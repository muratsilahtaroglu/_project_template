# github/ findings — staged batch verification & agent watchdogs (2026-07-16)

> Question: does a "Hermes watchdog for Claude Code" exist, and which repos carry reusable
> supervision patterns for bulk AI pipelines? Requested for the pilot-gate feature study
> (candidate v0.8.2). Distilled per rules.md §8; conclusions that drive the decision go to an
> ADR, not here.

## Verdict (repos)
No "Hermes watchdog for Claude Code" product exists — **clean negative**. The name belongs to
Nous Research's general-purpose autonomous agent framework; the community "watchdog" around it is
an uptime-restart cron, not output QA (see web/findings.md).

## Findings (claim | source | confidence | note)
- NousResearch/hermes-agent = self-improving personal agent (skills-from-experience, persistent
  memory, cron scheduler, 20+ messaging platforms, any LLM provider); NO Claude Code tie, NO
  output-verification watchdog | https://github.com/NousResearch/hermes-agent | high — verified
  twice (researcher subagent + main-agent fetch) | ~216k stars, MIT, v0.18.2 (2026-07-08). Very
  healthy, but a separate agent runtime — adopting it would violate the kit's zero-dependency
  stance and doesn't solve intermediate-output QA anyway.
- sypsyp97/claude-hermes = the only "Hermes × Claude Code" match: a personal-assistant daemon
  (cron/Telegram) with a 5-stage verify-gated self-evolution pipeline |
  https://github.com/sypsyp97/claude-hermes | high | 18 stars, pushed 2026-04-18 — pattern
  reference only, never a dependency.
- disler/claude-code-hooks-multi-agent-observability = all hook events → SQLite/WebSocket live
  dashboard for parallel agents; passive observation, no gating |
  https://github.com/disler/claude-code-hooks-multi-agent-observability | high | ~1.5k stars,
  pushed 2026-02-08, **no license file** — do not vendor code from it.
- hoangsonww/Claude-Code-Agent-Monitor = terminal dashboard + error watchdog rescanning
  transcripts every ~15s for API errors/rate limits |
  https://github.com/hoangsonww/Claude-Code-Agent-Monitor | medium (README not independently
  fetched) | 809 stars, MIT — infra-error watching, not output-quality watching.
- "Claude Code Watchdog" GitHub Action (CardScan.ai) = CI test-failure triage/auto-fix — a name
  collision, not agent-output supervision |
  https://github.com/marketplace/actions/claude-code-watchdog | high | v0.3.1, small publisher.
- anthropics/skills batches guide: "test with a small batch before scaling" |
  https://github.com/anthropics/skills/blob/main/skills/claude-api/python/claude-api/batches.md |
  medium (search summary, not fetched) | supports the pilot norm from Anthropic's own ecosystem.
- great-expectations/great_expectations_action = CI data-validation gate (failure flag halts the
  workflow) | https://github.com/great-expectations/great_expectations_action | medium-high |
  mechanism reference for "validation result blocks the pipeline".

## Takeaway for Keel
Nothing here is worth importing as a dependency; everything worth having is a **pattern** we can
encode with machinery the kit already ships (skills, hooks, verifier subagent). Live dashboards
are heavy stack additions; checkpointed gates fit the kit's zero-dep philosophy.
