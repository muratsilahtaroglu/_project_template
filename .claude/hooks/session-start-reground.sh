#!/usr/bin/env bash
# SessionStart hook (sources: startup|resume|clear|compact). stdout IS added to Claude's context
# (unlike PreCompact, which cannot inject). On a context RESET (compact|resume|clear) it emits a
# re-read directive to recover lost state; on a cold startup it emits a lighter orientation nudge
# (nothing was lost — no need to command "work only on ## Now"). Always emits memory-file cap
# warnings. Always exits 0 — never blocks a session.
set -u
DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Claude Code pipes a JSON payload with the trigger "source" on stdin; read it (non-fatal if absent).
payload="$(cat 2>/dev/null || true)"
source="$(printf '%s' "$payload" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([a-zA-Z]*\)".*/\1/p')"

case "$source" in
  compact|resume|clear)
    echo "[keel] Context was reset ($source) — re-read HANDOVER.md (TOP block = current state), LESSONS.md, and TASKS.md '## Now' to recover state before continuing; resume from a '## Now' item." ;;
  *)
    echo "[keel] Keel project — skim HANDOVER.md (top block) · LESSONS.md · TASKS.md '## Now' to get oriented (rules.md §1)." ;;
esac

# Cap checks (rules.md §9.33): warn when a memory file needs /distill. Thresholds mirror rules.md §1.4
# / §9.33 and HANDOVER.md's header — keep the three in sync if you change a cap.
warn_cap() { # $1=file $2=max_lines
  [ -f "$DIR/$1" ] || return 0
  lines=$(wc -l < "$DIR/$1" 2>/dev/null || true)
  lines=${lines:-0}
  if [ "$lines" -gt "$2" ]; then
    echo "[keel] $1 is ${lines} lines (cap ~$2) — run /distill before adding more."
  fi
}
warn_cap "HANDOVER.md" 200
warn_cap "LESSONS.md" 100
warn_cap "TASKS.md" 100

# Block-count check: >5 SESSION blocks in HANDOVER.md → rotation due.
# Count only dated block headings (### YYYY-MM-DD ...) — other ### headings (e.g. the area-handover
# index) and the unfilled <YYYY-MM-DD> placeholder must not inflate the count.
if [ -f "$DIR/HANDOVER.md" ]; then
  blocks=$(grep -cE '^### [0-9]{4}-[0-9]{2}-[0-9]{2}' "$DIR/HANDOVER.md" 2>/dev/null || true)
  blocks=${blocks:-0}
  if [ "$blocks" -gt 5 ]; then
    echo "[keel] HANDOVER.md has ${blocks} session blocks (max 5) — run /distill to rotate the oldest to docs/handover-archive.md."
  fi
fi
exit 0
