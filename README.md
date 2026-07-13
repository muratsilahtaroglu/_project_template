# Keel — Claude Code Starter Kit

*Like a ship's keel keeps a vessel on course, **Keel** keeps Claude Code (or any LLM) on course:
a discipline + security starter kit that makes your project consistent, traceable, and safe —
no drift across sessions, from the very first one.*

<p align="center">
  <img src="docs/assets/keel-demo.gif" width="760"
       alt="Keel demo: clone the kit → Claude runs the bootstrap and prunes it to fit → builds in phases → updates HANDOVER.md">
</p>

**Requires:** [Claude Code](https://claude.com/claude-code). The `.claude/` layer (permissions, hooks,
skills) is Claude-Code-native; the docs and discipline (`rules.md`, ADRs, `HANDOVER.md`, security guide)
are tool-agnostic and useful with any agent.

## Quick start
```bash
# 1) clone Keel as your new project, then start your own git history
git clone https://github.com/muratsilahtaroglu/claude-code-starter-kit.git my-project
cd my-project && rm -rf .git && git init
# 2) in Claude Code, let it tailor the template to THIS project before coding:
#    "Read CLAUDE.md, then run the bootstrap: prune what this project doesn't need and plan."
```
Not every project needs the whole template — the bootstrap prunes it to fit (with your approval).
See **How to use** below. **Already have a project?** Don't `rm -rf .git` — see
[Adopting into an existing project](#adopting-into-an-existing-project-brownfield).

### Or install just the tooling as a plugin
This repo is **also its own Claude Code plugin marketplace** — install the enforcement layer without cloning:
```text
/plugin marketplace add muratsilahtaroglu/claude-code-starter-kit
/plugin install keel@keel
```
That gives you the **skills** (namespaced: `/keel:handover` · `/keel:distill` · `/keel:phase-review` ·
`/keel:research` · `/keel:adopt`), the `researcher` + `verifier` **subagents**, and the memory/safety
**hooks** — across every repo, updated with `/plugin marketplace update`. It does **not** install the
discipline docs (`rules.md`, `HANDOVER/LESSONS/TASKS`, `docs/`) or the `.claude/settings.json` permissions
(plugins can't seed repo files or permission rules). The clone above is the full kit; the plugin is the
tooling half for teams that already have the docs or want the skills everywhere.

> **Purpose:** When starting a new project (you or your teammates), give Claude Code this folder as a
> **template**. The generic "working discipline" files inside help set up the project from day one as
> **professional, traceable, and secure**. No file contains a project name or project-specific detail —
> fill in the placeholders.

## When (not) to use Keel
Honest scoping: **solo developer, one machine, a weekend project?** Claude Code's built-in auto-memory +
compaction will mostly carry you — Keel's discipline would be overhead. Keel pays off when any of these
is true:
- **a team** — project memory must live in the repo and travel through git (built-in auto-memory is
  machine-local and never shared);
- **open source / CI** — enforced permissions + hooks, supply-chain checks, PR discipline;
- **a months-long project with tens of compactions** — block-rotated memory, an always-loaded lessons
  database, a cross-session task board.

And even then, you don't take all of it: the bootstrap prunes whatever *this* project doesn't need.

## The loop (why it doesn't drift)
```mermaid
flowchart LR
    New([new project]) --> Boot["🧭 bootstrap<br/>prune to fit · your approval"]
    Boot --> Phase["⚙️ phase<br/>build + test · no skipping"]
    Phase --> Docs["📝 update docs<br/>+ HANDOVER.md"]
    Docs --> Commit["✅ commit + push<br/>your approval"]
    Commit --> Phase
    Docs -. session ends .-> Mem[("🧠 HANDOVER.md<br/>durable memory")]
    Mem -. next session reads .-> Phase
```
The context window is volatile RAM; the repo is durable disk. Every phase writes what it did into
`HANDOVER.md` + the docs, so the next session (even after 10+ compactions) picks up without drift.

**The memory model** (three always-loaded, size-capped files + a zero-cost archive):

| File | What | Anti-bloat rule |
|---|---|---|
| `HANDOVER.md` | last **5 session blocks** (done · tried-failed · latest · next) | on overflow `/distill` rotates the oldest block |
| `LESSONS.md` | critical knowledge written **the moment it appears** (rules, must-run tests, gotchas, failures) — with your approval | ~100-line cap; dedup/merge; `SUPERSEDED`, never silently deleted |
| `TASKS.md` | cross-session task board (`Now` (max 3–5) · `Next` · `Discovered`), each item with a verifiable `done-when:` | ~100-line cap; **delete on done** — git is the archive |
| `docs/handover-archive.md` | raw rotated blocks, verbatim | never `@`-imported → zero context cost, grep on demand |

No vector DB, no external memory service — grep-able markdown beats embeddings at this scale
(Claude Code itself ships with agentic search and no index). `/distill` is the consolidation ritual:
rotate, dedup, promote 3×-applied lessons into rules/skills, lint for contradictions.

### Surviving compaction (the pincer)

<p align="center">
  <img src="docs/assets/keel-memory.gif" width="760"
       alt="Keel memory lifecycle: a mid-session rule is written to LESSONS.md the moment it appears, survives compaction via the PreCompact snapshot + SessionStart re-ground pincer, and /distill rotates the oldest HANDOVER block when the cap is hit">
</p>

When the context window fills up, Claude Code **compacts**: the conversation is squeezed into a lossy
summary. Anything said only in conversation can vanish — but the `@`-imported files are **re-injected
from disk** after every compaction. Keel exploits that with a two-sided pincer around the compact:

- **Before — `PreCompact` hook** (side effects only; it *cannot* inject instructions): snapshots
  `HANDOVER/LESSONS/TASKS` to `.claude/snapshots/` and warns if the handover looks stale.
- **After — `SessionStart` hook** (its output *is* injected into context): tells Claude to re-read the
  top HANDOVER block, `LESSONS.md`, and `TASKS.md ## Now`, and warns when a memory file needs `/distill`.
- **Standing directive in `CLAUDE.md`**: what every compaction summary must preserve (modified files,
  open tasks, test commands, unwritten agreements → write them to `LESSONS.md` first).

Compaction becomes a curation step, not an information-loss event.

## Two layers: guidance + enforcement
Rules alone can be ignored; Keel also wires the discipline into Claude Code's **native, deterministic** layer.

| Layer | Where | Enforced? |
|---|---|---|
| **Guidance** | `rules.md`, ADRs, `HANDOVER.md` | advisory — the working discipline |
| **Always in context** | `CLAUDE.md` `@`-imports `rules.md` + `HANDOVER.md` + `LESSONS.md` + `TASKS.md` | auto-loaded every session, re-injected after compaction |
| **Permissions** | `.claude/settings.json` | denies reading `.env`/secrets · asks before `git push` |
| **Hooks** | `.claude/hooks/` | blocks `rm -rf` · force-push · staging `.env` · pipe-to-shell |
| **Compaction safety** | SessionStart + PreCompact hooks | snapshot memory files before compact · re-ground ("re-read HANDOVER/LESSONS/TASKS") + cap warnings after |

## How to use
1. Copy the contents of this folder into the root of the new project.
2. **Bootstrap tailoring (rules.md §0.0):** have the AI first *understand the project*, then propose
   (a) which template parts are unnecessary for this project and should be removed (with reasons), and
   (b) which layout profile from `docs/layouts.md` (ML, service/API, CLI, ...) to instantiate.
   **Nothing is removed or added without user approval.** Not every project needs the whole template.
3. Fill in the `<...>` placeholders in `CLAUDE.md`, `.env.example`, and `docs/architecture.md`.
4. Choose and add a `LICENSE` before the first push (a folder with no license is "all rights reserved").
5. Tell Claude Code: *"First read CLAUDE.md, then plan."* (CLAUDE.md `@`-imports `rules.md` +
   `HANDOVER.md` + `LESSONS.md` + `TASKS.md`.)
6. Follow the discipline in `rules.md` and proceed in phases; update docs + `HANDOVER.md` at the end of
   each phase, then commit + push with approval.

## Adopting into an existing project (brownfield)
Keel isn't only for new projects — you can bring an **already-in-progress** project under its discipline.
The kit is *overlaid, never dumped on top*: **non-destructive is the hard rule** (rules.md §0, Mode B).
```bash
# clone the kit somewhere ELSE — never touch your project's .git
git clone https://github.com/muratsilahtaroglu/claude-code-starter-kit.git /tmp/keel
# add ONLY the files you don't already have (existing files are kept, never overwritten):
rsync -av --ignore-existing /tmp/keel/ /path/to/your-project/ --exclude '.git'
```
Then, in Claude Code, run **`/adopt`** (or: *"Adopt Keel into THIS project — don't overwrite my files, add
only what's missing, back-fill `docs/architecture.md` + `HANDOVER.md` from the current code, merge conflicts
by showing me a diff first, and propose the plan before changing anything."*). `/adopt` inventories every
path as **add · merge · defer**, reverse-engineers the docs from your real code, **seeds the memory layer**
(first `HANDOVER.md` block = what exists today; `LESSONS.md` = known gotchas; `TASKS.md ## Now` = the actual
next work), and migrates security (rules.md §7) gradually — without breaking a working build.

<p align="center">
  <img src="docs/assets/keel-adopt.gif" width="760"
       alt="Keel adopt flow: clone the kit elsewhere, rsync only missing files, then /adopt inventories add/merge/defer, keeps your git history, back-fills the docs and seeds the memory files — with your approval">
</p>

## Where your code lives (discipline vs. code)
Keel's files sit at the **root** because that's where the tooling requires them (Claude Code reads the
root `CLAUDE.md`; `.gitignore` / `pyproject.toml` must be at root). They don't mix *into* your code — they
sit *beside* it, exactly like `package.json` or `.eslintrc` in any project. Your actual application code
lives in a **separate source tree** the bootstrap creates from a `docs/layouts.md` profile:

```text
your-project/
├── CLAUDE.md · rules.md · HANDOVER.md · LESSONS.md · TASKS.md   ← discipline (fixed, at root)
├── .claude/ · docs/ · tests/ · config/ · requirements/            ← support (fixed)
└── src/<app-or-package>/   (+ data/ entrypoint/ notebooks/ for ML)   ← YOUR CODE (added at bootstrap)
```

The kit ships **no `src/`** — it is NOT part of the shipped tree below; the bootstrap proposes the right
layout for *your* project type (service / CLI / ML / mix) and you approve it, then **all application code
goes under `src/`** and nothing loose lands at the root (rules.md §3.10). LLM-app runtime prompts (if any)
are versioned files under `src/`, read from disk. **New project:** the shell comes first, you add code
inside `src/`. **Existing project:** your code already exists and the shell wraps around it via `/adopt` —
nothing in your `src/` moves. Keel is a **shell that wraps your project, not a skeleton you pour code into.**

## Contents (all generic / project-agnostic)
```text
claude-code-starter-kit/
│
├── CLAUDE.md                 # project constitution — Claude reads it first (@-imports the 4 below)
├── rules.md                  # working discipline: docs · tests · security · git · research · memory · judgment
├── HANDOVER.md               # session memory: last 5 blocks (done · tried-failed · latest · next)
├── LESSONS.md                # critical knowledge written the moment it appears ([rule][test][fail][gotcha])
├── TASKS.md                  # cross-session task board (Now (3–5) · Next · Discovered; delete-on-done)
├── README.md                 # this file
├── CONTRIBUTING.md           # how to contribute to the kit itself
├── LICENSE                   # MIT
│
├── .claude/                  # ⚙️  Claude Code layer — guidance + deterministic enforcement
│   ├── settings.json         #     permissions: deny reading secrets · ask before push · hook registration
│   ├── hooks/                #     block-dangerous · handover reminder · pre-compact snapshot ·
│   │                         #     session-start re-ground (+ memory-cap warnings)
│   ├── skills/               #     invokable workflows: /handover · /phase-review · /research · /adopt · /distill
│   ├── agents/               #     reusable subagents: researcher · verifier (isolated context)
│   ├── hooks/hooks.json      #     plugin-mode hook registration (standalone mode uses settings.json)
│   └── rules/                #     optional path-scoped rules (load only when matching files are touched)
│
├── .claude-plugin/           # 🔌 install the tooling via /plugin (this repo is its own marketplace)
│   ├── plugin.json           #     bundles .claude/ skills · agents · hooks as the "keel" plugin
│   └── marketplace.json      #     self-hosted marketplace (/plugin marketplace add <repo>)
│
├── docs/                     # 📚 long-form documentation
│   ├── architecture.md       #     live module map (updated on every structural change)
│   ├── security.md           #     supply-chain security guide (pin · hash · non-root · .pth · CI)
│   ├── layouts.md            #     per-project layout profiles (ML · service/API · CLI)
│   ├── steering.md           #     which Claude Code mechanism for what (skill/hook/rule/subagent/…)
│   ├── user_manual.md        #     end-user guide skeleton
│   ├── handover-archive.md   #     raw rotated HANDOVER blocks (never imported — zero context cost)
│   ├── assets/               #     README media (demo · memory-lifecycle · adopt GIFs)
│   └── adr/                  #     architecture decision records (template + index)
│
├── requirements/             # 📦 all dependency manifests (see requirements/README.md)
│   ├── base.txt · base.lock  #     runtime deps — pinned (==) + hash-locked
│   └── dev.txt  · dev.lock   #     dev tooling — never enters the prod image
│
├── config/                   # non-secret parameters per env (local.yaml · prod.yaml)
├── tests/                    # unit · integration · e2e · fixtures
├── scratch/                  # throwaway experiments (probes · one_off · experiments)
├── reports/                  # generated reports
├── research/                 # opt-in external research trail
│   └── github · articles · linkedin · huggingface · web   → findings.md per source
│
├── .github/                  # CI + PR template
│   ├── workflows/ci.yml      #     hash-verify · pip-audit · .pth scan on every PR/push
│   └── PULL_REQUEST_TEMPLATE.md  # Definition-of-Done checklist (mirrors rules.md)
│
├── Dockerfile · .dockerignore · docker-compose.yml   # multi-stage, non-root container skeleton
├── Makefile                  # runnable targets: setup · test · lint · lock · audit
├── pyproject.toml            # tool config only: ruff (+ security lint S) + pytest
├── .pre-commit-config.yaml   # gitleaks + .env guard + hygiene hooks
└── .editorconfig · .env.example · .gitignore
```

## Philosophy (why this discipline?)
- **Fit the project, don't force the template:** the bootstrap step (rules.md §0.0) prunes unneeded
  parts and instantiates the right layout profile — always with user approval.
- **Traceability:** every decision goes into an ADR, every structural change into `architecture.md`,
  every session into `HANDOVER.md`. The project stays stable even after 10+ compactions.
- **Memory with a lifecycle, not a landfill:** always-loaded files are size-capped; old detail rotates
  to a never-loaded archive; critical facts are written the moment they appear (`LESSONS.md`) and
  consolidated by `/distill`. Files + grep beat vector DBs at this scale — no external memory service.
- **Order:** throwaway code stays in `scratch/`, the main tree stays clean.
- **Security from day one:** dependency pinning + hashing + non-root + secret hygiene from the start.
- **Enforced, not just advised:** the discipline is wired into Claude Code's native layer (see the
  table above) — rules are guidance; permissions and hooks are enforced.
- **Controlled progress:** phases are not skipped; each phase ends with a working product + an
  approved commit/push.
