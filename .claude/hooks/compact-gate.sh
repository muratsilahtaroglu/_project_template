#!/usr/bin/env bash
# PreCompact hook, matcher "manual" — the ENFORCEMENT the warning lacked: block a manual /compact
# while the disk is stale (tree changed this session but HANDOVER.md untouched), with "run
# /keel-compact first". Exit 2 = block (per current docs, "Exit code 2 behavior": PreCompact blocks
# compaction); on older CLIs exit 2 only showed stderr — so this degrades to a loud warning, never
# breaks. Auto-compact is NEVER blocked (a blocked auto-compact could wedge a full-context session):
# the matcher restricts us to manual, and a payload check backstops CLIs that ignore the matcher.
set -u
DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
payload="$(cat 2>/dev/null || true)"

# Not a Keel project (no HANDOVER.md) → never gate. Matters when the keel PLUGIN is installed
# globally: without this, every dirty non-Keel repo would have /compact blocked.
[ -f "$DIR/HANDOVER.md" ] || exit 0

# Auto-compact backstop: if a CLI ignores the "manual" matcher, still let auto pass.
printf '%s' "$payload" | grep -q '"trigger"[[:space:]]*:[[:space:]]*"auto"' && exit 0

# Emergency bypasses (documented in the block message):
#  - one-shot marker:  touch .claude/compact-force && /compact   (consumed on use)
#  - inline token:     /compact keel-force   (works when the CLI forwards custom instructions)
if [ -f "$DIR/.claude/compact-force" ]; then rm -f "$DIR/.claude/compact-force"; exit 0; fi
printf '%s' "$payload" | grep -qi 'keel-force' && exit 0

git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
# Dirty check — telemetry must never trigger the gate: exclude .claude/ritual-log (normally
# git-ignored anyway; this guards projects that skipped the .gitignore hunk) and the
# regenerable stats report it feeds.
changed="$(git -C "$DIR" status --porcelain 2>/dev/null | grep -vE '\.claude/ritual-log|reports/ritual-stats\.md|^\?\? reports/$')"
[ -z "$changed" ] && exit 0                                            # clean tree → nothing unsaved
# HANDOVER.md modified in the working tree → the ritual ran (or is running) → fresh enough.
[ -n "$(git -C "$DIR" status --porcelain -- HANDOVER.md 2>/dev/null)" ] && exit 0
# HANDOVER committed as the most recent history touching it AND that commit is FRESH (≤30 min):
# covers "/keel-handover → approved commit → compact right after". The freshness bound matters —
# without it, any session starting from a handover-carrying commit (the normal end-of-session
# shape) would have behind=0 forever and the gate would never close.
last=$(git -C "$DIR" log -1 --format=%H -- HANDOVER.md 2>/dev/null)
if [ -n "$last" ]; then
  behind=$(git -C "$DIR" rev-list --count "${last}..HEAD" 2>/dev/null || echo 0)
  age=$(( $(date +%s) - $(git -C "$DIR" log -1 --format=%ct -- HANDOVER.md 2>/dev/null || echo 0) ))
  [ "${behind:-0}" -eq 0 ] && [ "$age" -le 1800 ] && exit 0
fi

echo "$(date '+%F %T') compact-gate BLOCK: stale manual /compact" >> "$DIR/.claude/ritual-log" 2>/dev/null || true
echo "[keel] /compact BLOCKED: the tree changed this session but HANDOVER.md was not updated — the summary would be the only record of this session. Run /keel-compact (refreshes HANDOVER/LESSONS/TASKS/PLAN, then hands you back to /compact). Emergency bypass: '/compact keel-force' or 'touch .claude/compact-force' then /compact." >&2
exit 2
