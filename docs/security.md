# docs/security.md — Supply-Chain Security (GENERAL GUIDE)

> Project-agnostic. Context: malicious versions pushed to package registries like PyPI/npm (e.g. a real
> case: a malicious library version harvested and exfiltrated SSH keys/`.env`/cloud credentials).
> **Lesson:** any project using open `>=` ranges is a potential target. Rules: `rules.md §7`.

## Tier 1 — Do immediately
| Measure | How | Effect |
|---|---|---|
| Exact version pinning | All `>=`/`~=`/`^` → `==` | Malicious new versions don't arrive automatically |
| Lock file | `pip-compile --generate-hashes` (or `uv lock`) → `requirements.lock`; Node: lockfile + `npm ci` | Reproducible build |
| Non-root container | Dockerfile `USER appuser` | Privilege escalation is harder |
| Secret management | `.env` git-ignored; Vault/secret-store in prod | Credential theft is harder |
| `.dockerignore` | `.env`/`.git`/`secrets` never enter the build context | No secrets leak into the image |

## Tier 2 — First sprint
| Measure | How | Effect |
|---|---|---|
| Hash verification | `pip install --require-hashes -r requirements.lock` | Same version, different content → fails |
| Multi-stage build | Separate builder + prod stage; build tools don't ship to prod | Smaller attack surface |
| `.pth` injection scan | Scan `.pth` files in build+CI; **high-signal** pattern: `exec(\|subprocess\|os.system\|socket\|eval(\|marshal\|base64\|__import__` | Blocks autorun injection |
| pip-audit CI step | `pip-audit -r requirements.lock` in CI | Catches known CVEs |
| Network policy | Only necessary egress allowed in prod | Harder to exfiltrate |

> **Note — common `.pth`-scan mistake:** a naive `import` grep false-positives on setuptools'
> `distutils-precedence.pth` file and breaks the build. That's why only high-signal patterns are scanned.

## Tier 3 — Planned
| Measure | Effect |
|---|---|
| SBOM (Software Bill of Materials) | Fast identification of affected projects |
| Sigstore signature verification | Detects counterfeit packages |
| Runtime monitoring (unexpected outbound logging) | Attack detection |
| Dependency review bot (Renovate/Dependabot + manual approval) | Controlled updates |
| Private package mirror | Reduces external dependency exposure |

## CI security job (summary)
`pip install --require-hashes -r requirements.lock` → `.pth` scan → `pip-audit`. On every PR and `main` push.

## New dependency procedure
1. Is it actually necessary? Check for typosquatting/name + repo health/download count.
2. Add to `requirements.txt` with `==` → refresh the lock (`pip-compile --generate-hashes`).
3. `pip-audit -r requirements.lock` → no CVEs → proceed → rebuild + test.

## 🚨 Emergency checklist (if a similar attack is detected)
- [ ] Pin/downgrade the affected package version.
- [ ] Rebuild all containers from a clean image.
- [ ] Rotate secrets (secret-store/Vault).
- [ ] Rotate SSH keys.
- [ ] Rotate cloud credentials (AWS/GCP).
- [ ] Change all passwords/tokens in `.env`.
- [ ] Review outbound network logs (last 48 hours).
- [ ] Check git history of affected services.
