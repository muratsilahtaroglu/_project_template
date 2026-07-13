---
paths:
  - "**/migrations/**"
  - "**/alembic/versions/**"
---
# Migrations are append-only (EXAMPLE — delete or adapt for your project)

Never edit or delete a migration that may already have run somewhere. To change the schema, add a **new**
migration. Migrations are **forward-only and idempotent** (`IF NOT EXISTS`, guarded DDL); user/message
data is never touched by a schema migration (rules.md §5.13).

This file only loads when Claude reads something under a `migrations/` (or Alembic `versions/`) path —
that's the point of a path-scoped rule. If your project has no migrations, delete this file at bootstrap.
