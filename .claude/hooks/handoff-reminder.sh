#!/usr/bin/env bash
# Stop hook — gentle, NON-blocking nudge to update HANDOVER.md when the working tree changed
# this session but HANDOVER.md wasn't touched (rules.md §1.4). Always exits 0 (never blocks stopping).

changed="$(git status --porcelain 2>/dev/null)"
[ -z "$changed" ] && exit 0                             # clean tree → nothing to hand over
printf '%s' "$changed" | grep -q 'HANDOVER.md' && exit 0  # already updated → quiet

# Advisory only. `systemMessage` is shown to the user; exit 0 lets the turn end normally.
printf '{"systemMessage":"Reminder (rules.md §1.4): the working tree changed but HANDOVER.md was not updated this session — consider updating it before ending."}\n'
exit 0
