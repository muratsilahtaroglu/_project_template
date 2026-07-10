#!/usr/bin/env bash
# PreToolUse(Bash) hook — blocks a few catastrophic / secret-leaking commands (rules.md §5,§6).
# Contract: read the tool call as JSON on stdin; exit 2 = BLOCK the command, exit 0 = allow.
# Deliberately conservative (few, high-signal patterns) so it doesn't nag on normal work. Tune freely.

cmd="$(python3 -c 'import sys, json; print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

block() { echo "BLOCKED by .claude/hooks/block-dangerous.sh: $1" >&2; exit 2; }

# 1) Recursive delete of root / home / cwd (allows rm -rf ./subdir and absolute project paths).
if printf '%s' "$cmd" | grep -Eq '\brm\b' \
   && printf '%s' "$cmd" | grep -Eq '[[:space:]]-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+(/|/\*|~|\$HOME|\.)([[:space:]]|$)'; then
  block "recursive delete of root/home/cwd"
fi

# 2) Force push (allow the safer --force-with-lease).
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push' \
   && printf '%s' "$cmd" | grep -Eq '(--force([[:space:]]|=|$)|[[:space:]]-f([[:space:]]|$))' \
   && ! printf '%s' "$cmd" | grep -q 'force-with-lease'; then
  block "git push --force — use --force-with-lease and get approval (rules.md §6)"
fi

# 3) Staging a real .env (but not .env.example).
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+add' \
   && printf '%s' "$cmd" | grep -Eq '\.env([[:space:]]|$)' \
   && ! printf '%s' "$cmd" | grep -q '\.env\.example'; then
  block "staging a .env file — secrets must never be committed (rules.md §5)"
fi

# 4) Piping remote content straight into a shell.
if printf '%s' "$cmd" | grep -Eq '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh([[:space:]]|$)'; then
  block "piping remote content into a shell (supply-chain risk, docs/security.md)"
fi

exit 0
