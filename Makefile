.PHONY: setup setup-dev lint test run lock audit

setup:  ## Install pinned runtime deps with hash verification
	pip install --require-hashes -r requirements/base.lock

setup-dev:  ## Install dev tooling (pytest/ruff/...) with hash verification
	pip install --require-hashes -r requirements/dev.lock

lock:  ## Refresh both lock files from the .txt files
	pip-compile --generate-hashes -o requirements/base.lock requirements/base.txt
	pip-compile --generate-hashes -o requirements/dev.lock requirements/dev.txt

audit:  ## Check locked deps for known CVEs
	pip-audit -r requirements/base.lock
	pip-audit -r requirements/dev.lock

lint:  ## Lint + format-check with ruff (config in pyproject.toml)
	ruff check .
	ruff format --check .

test:  ## Run the full test suite
	pytest tests/

run:  ## <wire up the app entrypoint>
	@echo "TODO: configure run command"
