#!/usr/bin/env bash
# SessionStart hook (all sources: startup|resume|clear|compact) — re-grounds after a context reset.
# stdout from a SessionStart hook is ADDED TO CLAUDE'S CONTEXT (unlike PreCompact, which cannot inject).
# Emits: (1) a re-read directive, (2) memory-file cap warnings so /distill runs before bloat hurts.
# Always exits 0 — never blocks a session.
set -u
DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo "[keel] Re-ground after context reset: re-read HANDOVER.md (TOP block = current state), LESSONS.md, and TASKS.md '## Now' before continuing. Work only on a '## Now' item."

# Cap checks (rules.md §9): warn when a memory file needs /distill.
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
