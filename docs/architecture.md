# docs/architecture.md — Live Architecture Map (TEMPLATE)

> Updated on every structural change. What each significant file/module does. Status: ✅ exists · 🟡 skeleton · ⬜ planned.

## Component overview
```
<text diagram: client → API → service/worker → database/external services>
```

## Module map
| Module / file | Status | Purpose |
|---|---|---|
| `<path>` | 🟡 | <what it does> |

## Reused patterns
- <which off-the-shelf pattern/from where> → <how it's used here>

## Runtime prompts (LLM apps only — omit for non-LLM projects)
Prompts the app sends at runtime, kept as versioned files under `src/` and read from disk (never
embedded as strings): <list>.
