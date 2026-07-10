# requirements/ — dependency manifests

All Python dependency files live here (kept out of the cluttered project root). Rules: `rules.md §7`,
details: `docs/security.md`.

| File | What | Edited by |
|---|---|---|
| `base.txt` | direct **runtime** deps — exact `==` pins only | you (by hand) |
| `base.lock` | full transitive tree + **hashes** for runtime | `pip-compile` (auto) |
| `dev.txt` | dev/test tooling (pytest, ruff, ...) — never in the prod image | you (by hand) |
| `dev.lock` | full transitive tree + hashes for dev | `pip-compile` (auto) |

```bash
make lock     # regenerate base.lock + dev.lock from the .txt files
make setup    # pip install --require-hashes -r requirements/base.lock
make setup-dev
make audit    # pip-audit both lock files
```

Never hand-edit the `.lock` files. `>=` / `~=` / `^` are forbidden — exact `==` only (supply-chain safety).
