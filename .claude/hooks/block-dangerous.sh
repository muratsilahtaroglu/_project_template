#!/usr/bin/env bash
# PreToolUse(Bash) hook — blocks a few catastrophic / secret-leaking commands (rules.md §5,§6).
# Contract: read the tool call as JSON on stdin; exit 2 = BLOCK the command, exit 0 = allow.
# Deliberately conservative (few, high-signal patterns) so it doesn't nag on normal work. Tune freely.

# Fail-open trade-off (documented): if python3 is missing or stdin isn't JSON, we allow with a stderr
# note rather than blocking every Bash call — this hook is belt-and-suspenders on top of rules.md, and
# a broken guard must not brick the session. The gitleaks pre-commit hook + CI are the backstops.
cmd="$(python3 -c 'import sys, json; print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))' 2>/dev/null)" \
  || echo "block-dangerous.sh: could not parse hook input — allowing (check python3)" >&2
[ -z "$cmd" ] && exit 0

block() { echo "BLOCKED by .claude/hooks/block-dangerous.sh: $1" >&2; exit 2; }

# 1) Recursive delete of root / home / cwd (allows rm -rf ./subdir and absolute project paths).
#    ('rm' matched without \b — a GNU extension that silently never matches on BSD/macOS grep.)
#    The `[/*]*` after the target catches trailing chars that would otherwise bypass the guard
#    (rm -rf ~/  ·  ~/*  ·  //  ·  /*/  ·  $HOME/) while still allowing ~/proj, /abs/proj, ./subdir.
if printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]_])rm([^[:alnum:]_]|$)' \
   && printf '%s' "$cmd" | grep -Eq '[[:space:]]-[a-zA-Z]*[rf][a-zA-Z]*[[:space:]]+(/|~|\$HOME|\.)[/*]*([[:space:]]|$)'; then
  block "recursive delete of root/home/cwd"
fi

# 2) Force push (allow the safer --force-with-lease).
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+push' \
   && printf '%s' "$cmd" | grep -Eq '(--force([[:space:]]|=|$)|[[:space:]]-f([[:space:]]|$))' \
   && ! printf '%s' "$cmd" | grep -q 'force-with-lease'; then
  block "git push --force — use --force-with-lease and get approval (rules.md §6)"
fi

# 3) Staging a real .env — including variants (.env.production/.env.local/...) but not .env.example.
#    The allowed name is STRIPPED first, so `git add .env .env.example` can't ride along on the
#    exclusion, and the variant pattern catches `.env.<anything>`.
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+add'; then
  stripped="$(printf '%s' "$cmd" | sed 's/\.env\.example//g')"
  if printf '%s' "$stripped" | grep -Eq '(^|[[:space:]"'\''=/])\.env(\.[A-Za-z0-9_-]+)?([[:space:]"'\'']|$)'; then
    block "staging a .env file — secrets must never be committed (rules.md §5)"
  fi
fi

# 4) Piping remote content straight into a shell.
if printf '%s' "$cmd" | grep -Eq '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh([[:space:]]|$)'; then
  block "piping remote content into a shell (supply-chain risk, docs/security.md)"
fi

exit 0
