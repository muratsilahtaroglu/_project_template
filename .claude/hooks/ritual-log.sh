#!/usr/bin/env bash
# Multi-event telemetry hook — appends one line per interesting event to `.claude/ritual-log`
# (git-ignored, machine-local): skills invoked via the Skill tool, compact boundaries (manual/auto),
# session starts. Answers "which skills/hooks ran, how often, in which compact interval" — grep the
# file; compact/session lines are the interval boundaries. The blocking hooks (block-dangerous,
# compact-gate) also append their BLOCK events here. Self-trims to the last 1000 lines once per
# session. Always exits 0 — telemetry must never break work (every write is best-effort).
# One script, three registrations: PreToolUse(matcher Skill) + PreCompact + SessionStart.
set -u
DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG="$DIR/.claude/ritual-log"
payload="$(cat 2>/dev/null || true)"
get() { printf '%s' "$payload" | python3 -c "import sys,json;d=json.load(sys.stdin);print($1)" 2>/dev/null || true; }

ev="$(get "d.get('hook_event_name','')")"
case "$ev" in
  PreToolUse)   line="skill $(get "d.get('tool_input',{}).get('skill','?')")" ;;
  UserPromptExpansion)
                # user-TYPED commands, built-ins included (/compact, /code-review, /keel-*) —
                # the gap the Skill-tool matcher can't see (it only fires on agent-side calls)
                line="command $(get "d.get('command_name', d.get('command','?'))")" ;;
  PreCompact)   line="compact $(get "d.get('trigger','?')")" ;;
  SessionStart) line="session-start $(get "d.get('source','?')")"
                # trim once per session — keep the last 1000 lines
                if [ -f "$LOG" ]; then tail -n 1000 "$LOG" > "$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG" 2>/dev/null; fi ;;
  *)            line="event ${ev:-unknown}" ;;
esac

mkdir -p "$DIR/.claude" 2>/dev/null || exit 0
printf '%s %s\n' "$(date '+%F %T')" "$line" >> "$LOG" 2>/dev/null || true
exit 0
