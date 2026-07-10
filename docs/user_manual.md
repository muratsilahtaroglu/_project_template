# docs/user_manual.md — <PROJECT NAME> User Guide (TEMPLATE)

> Updated as features land.

## 1. What is <Project>?
<2-3 sentences for the end user.>

## 2. Installation (operator)
Prerequisites: <...>
```bash
cp .env.example .env      # fill in the values (secrets stay in .env)
<setup/run commands — see also `make setup` / `make run` in the Makefile>
```

## 3. Usage (end user)
<Step-by-step basic flow.>

## 4. Configuration
Secrets live in `.env` (see `.env.example`); non-secret parameters in `config/<env>.yaml`
(see `config/README.md`). Key settings: <...>

## 5. FAQ
- <question> — <answer>
