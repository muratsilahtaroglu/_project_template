# config/ — non-secret parameters, per environment

Split of responsibilities:
- **`.env`** → secrets + machine-local values (passwords, API keys, ports). Git-ignored (rules.md §5).
- **`config/<env>.yaml`** → non-secret parameters (thresholds, model names, feature flags, batch sizes).
  Tracked in git, code-reviewed like code.

Code selects the file by the `ENV` variable from `.env` (e.g. `ENV=dev` → `config/local.yaml`,
`ENV=prod` → `config/prod.yaml`). Never put a secret in a yaml here — it would land in git history.
