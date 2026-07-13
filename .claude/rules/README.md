# .claude/rules/ — optional path-scoped rules

`rules.md` at the repo root is the **always-loaded constitution** (universal discipline, `@`-imported
every session). This folder is for **optional, FILE-SCOPED constraints** that only matter when specific
files are touched — a rule with a `paths:` frontmatter loads *only* when Claude reads a matching file,
so it stays out of context (and off the always-on token budget) during unrelated work.

**Use a path-scoped rule** for a constraint that applies to some files but not the whole project — e.g.
"migrations are append-only", "API handlers must validate input", "generated files are never edited by
hand". See `migrations-append-only.md` for the format (delete/adapt it — it's an example).

**Keep it in `rules.md` instead** when the rule must *always* apply: path-scoped rules are **lost after
compaction until a matching file is touched again** (unlike `rules.md`, which is re-injected from disk
every compaction). So must-always-hold discipline (handover, security posture, judgment) belongs in
`rules.md`; only genuinely file-local constraints belong here.

(Mechanism trade-offs across skills / hooks / subagents / rules / CLAUDE.md: see `docs/steering.md`.)
