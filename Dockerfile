# Multi-stage, non-root skeleton (docs/security.md Tier 1-2). Fill in <...>.

# --- Builder stage: only this stage has build tools ---
FROM python:3.12-slim AS builder

WORKDIR /build
COPY requirements/ ./requirements/

RUN pip install --require-hashes --prefix=/install -r requirements/base.lock

# --- Runtime stage: no build tools, no secrets, non-root ---
FROM python:3.12-slim AS runtime

RUN useradd --create-home --shell /usr/sbin/nologin appuser
COPY --from=builder /install /usr/local
WORKDIR /app
COPY . .

USER appuser

# ENV <...>=<...>
EXPOSE <API_PORT>
CMD ["<entrypoint, e.g. python -m app>"]
