# docs/layouts.md — Source Layout Profiles (per project type)

> The template root deliberately ships **no** source layout — projects differ. During **bootstrap**
> (rules.md §0.0) the AI proposes the matching profile below (or a mix), the user approves, and only
> then are the folders created. Everything here composes with the always-present discipline base
> (CLAUDE.md, rules.md, HANDOVER.md, docs/, tests/, scratch/, prompts/, .claude/skills/, config/, CI, Docker)
> plus the opt-in `research/` trail (rules.md §8).

## Profile: ML / Data Science
```
config/
├── local.yaml            # dev parameters
└── prod.yaml             # deployment parameters
data/                     # data lifecycle — numbered stages
├── 01-raw/               # raw source data (immutable)
├── 02-preprocessed/      # cleaned datasets
├── 03-features/          # engineered features
└── 04-predictions/       # model outputs
entrypoint/
├── train.py              # orchestrates the full training pipeline
└── inference.py          # batch or real-time predictions
notebooks/                # EXPLORATION ONLY — never production logic
├── EDA.ipynb
└── Baseline.ipynb
src/
├── pipelines/
│   ├── feature_eng_pipeline.py
│   ├── training_pipeline.py
│   └── inference_pipeline.py
└── utils.py
tests/                    # already in the base (unit/integration/e2e/fixtures)
```
Notes:
- **Notebooks are exploration only** — same spirit as the `scratch/` rule (rules.md §3): anything that
  proves out graduates into `src/` (+architecture.md); notebooks never become production logic.
- `data/` is **already git-ignored** by the base `.gitignore`; also add `data/` and `notebooks/` to
  `.dockerignore` (large, not needed in the image).
- Model/experiment tracking (MLflow/W&B) and a conda `env.yaml` (if used instead of pip) are decided
  via ADR; pin exact versions either way (rules.md §7).

## Profile: Backend service / API
```
config/
├── local.yaml
└── prod.yaml
src/<app>/
├── api/                  # routers / handlers (thin — no business logic)
├── services/             # business logic
├── models/               # ORM / schema definitions
├── clients/              # external service clients (LLM, queue, ...)
└── main.py               # app entrypoint
migrations/               # DB schema migrations (alembic etc.)
tests/                    # base
```
Notes: request/response validation at the edge (rules.md §5.13); every external dependency behind a
client class so it can be faked in `tests/fixtures/`.

## Profile: CLI tool / library
```
src/<package>/
├── __init__.py
├── cli.py                # argument parsing only — logic lives in modules
└── <modules>.py
tests/                    # base
```
Notes: keep `cli.py` thin so the library surface stays importable and testable.

## Mixing profiles
Combined projects (e.g. API + ML pipeline) take the union of the relevant profiles under one `src/`;
prune anything unused at bootstrap. Record the chosen layout in `docs/architecture.md` (module map) and
the decision in an ADR if it deviates from these profiles.
