SHELL := /bin/bash # Toutes les commandes seront exécutées par bash
.ONESHELL: # Toutes les lignes d’une même cible sont exécutées dans le même shell bash.
.SHELLFLAGS := -eu -o pipefail -c # Le shell s’arrête immédiatement si une commande retourne un code ≠ 0, si une variable non définie, et si une commande n’est pas trouvée.
# -----------------------------
# Config
# -----------------------------
PYTHON      ?= python3.12
VENVDIR     ?= ./venv  # ADK extension expects 'venv'
VENVDIR_CLEAN := $(strip $(VENVDIR))

ENV_FILE    ?= ./.env.sdk
WXO_VERSION ?= 2.3.0

# Feature flags (edit as needed)
OBSERVABILITY_TOOL ?= --with-langfuse   # --with-ibm-telemetry --with-langfuse
OPTIONAL_TOOLS     ?= --with-langflow # --with-langflow --with-doc-processing

# Binaries inside venv
PIP  := $(VENVDIR_CLEAN)/bin/pip
PY   := $(VENVDIR_CLEAN)/bin/python
ORCH := $(VENVDIR_CLEAN)/bin/orchestrate

PYTEST := $(PY) -m pytest

SLEEP ?= sleep 1
LOGS_POLL ?= 2

# Try to include env file if present (do not fail if missing)
-include $(ENV_FILE)

# Use WO_INSTANCE_ALIAS if specified
ifdef WO_INSTANCE_ALIAS
	WXO_SAAS_ENV := $(WO_INSTANCE_ALIAS)
else
	WXO_SAAS_ENV := wxo-saas
endif

default: help # quand tu tapes simplement make -> exécute help

# -----------------------------
# Helpers
# -----------------------------
.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Setup:"
	@echo "  check              verify python + show paths/versions"
	@echo "  install            create venv and install prerequisites"
	@echo "  upgrade            upgrade orchestrate CLI to WXO_VERSION"
	@echo "  cleanup            remove the virtual environment"
	@echo "  reinstall          stop local server, delete venv, reinstall"
	@echo "  bootstrap           init folders, install deps, start server, open chat ..."
	@echo "  bin-orchestrate     create ./bin/orchestrate wrapper for CLI usage"
	@echo "  use                 print PATH export to enable ./bin on this terminal"
	@echo ""
	@echo "Local server:"
	@echo "  server_start        start local server"
	@echo "  server_logs         show local server logs"
	@echo "  logs                show server logs"
	@echo "  logs-follow         follow server logs (polling)"
	@echo "  status              show local server status (best-effort)"
	@echo "  server_stop         stop local server"
	@echo "  server_restart      restart local server"
	@echo "  reset               reset local environment"
	@echo "  prune-cpd           prune docker images (cpd only)"
	@echo "  purge               DELETE local VM and all its data (requires confirm)"
	@echo ""
	@echo "SaaS / env:"
	@echo "  register_saas       register SaaS environment"
	@echo "  activate_saas       activate SaaS environment"
	@echo "  activate_local      activate Local environment"
	@echo ""
	@echo "Project:"
	@echo "  init-structure      create project folder structure (agents, tools, etc.)"
	@echo "  connections         deploy connections"
	@echo "  deploy              deploy tools and agents"
	@echo "  list                list connections, tools and agents"
	@echo "  test                run pytest"
	@echo "  chat                launch chat"
	@echo "  copilot             launch copilot"
	@echo ""
	@echo "Debug:"
	@echo "  print-env           print key env vars read from $(ENV_FILE)"
	@echo "  doctor              diagnose environment (non-destructive)"
	@echo ""
	@echo "Notes:"
	@echo "  - Env file used by server/chat/copilot: $(ENV_FILE)"
	@echo "  - Venv folder expected by ADK extension: $(VENVDIR)"

.PHONY: check
check:
	@echo "System python: $$(command -v $(PYTHON) || true)"
	@if ! command -v $(PYTHON) >/dev/null 2>&1; then \
		echo "ERROR: $(PYTHON) not found. Install Python 3.12 and retry."; \
		exit 1; \
	fi
	@echo "System python version: $$($(PYTHON) --version)"
	@$(PYTHON) -c 'import sys; assert sys.version_info[:2]==(3,12), f"Expected Python 3.12, got {sys.version}"'
	@if [ -x "$(PY)" ]; then \
		echo "Venv python: $(PY) ($$($(PY) --version))"; \
		echo "Venv orchestrate: $(ORCH) ($$($(ORCH) --version 2>/dev/null || echo 'version unavailable'))"; \
	else \
		echo "Venv not found yet. Run: make install"; \
	fi
	@if [ -f "$(ENV_FILE)" ]; then \
		echo "Env file: $(ENV_FILE) (present)"; \
	else \
		echo "Env file: $(ENV_FILE) (MISSING)"; \
		echo "  Server/chat/copilot may fail without it."; \
	fi

.PHONY: print-env
print-env:
	@echo "WXO_SAAS_ENV=$(WXO_SAAS_ENV)"
	@echo "WO_INSTANCE=$${WO_INSTANCE:-}"
	@echo "WO_API_KEY=$${WO_API_KEY:+(set)}"
	@echo "WO_INSTANCE_ALIAS=$${WO_INSTANCE_ALIAS:-}"

.PHONY: _require_orch _require_env _require_venv _require_scripts_dir
_require_orch:
	@if [ ! -x "$(ORCH)" ]; then \
		echo "ERROR: orchestrate not installed. Run: make install"; \
		exit 1; \
	fi

_require_env:
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "ERROR: $(ENV_FILE) missing. Create it or set ENV_FILE=..."; \
		exit 1; \
	fi

_require_venv:
	@if [ ! -x "$(PY)" ]; then \
		echo "ERROR: venv not found. Run: make install"; \
		exit 1; \
	fi

_require_scripts_dir:
	@if [ ! -d "scripts" ]; then \
		echo "ERROR: scripts/ directory not found"; \
		exit 1; \
	fi

.PHONY: _require_wo_instance _require_wo_api_key

_require_wo_instance:
	@if [ -z "$${WO_INSTANCE:-}" ]; then \
		echo "ERROR: WO_INSTANCE is not set. Add it to $(ENV_FILE)"; \
		exit 1; \
	fi

_require_wo_api_key:
	@if [ -z "$${WO_API_KEY:-}" ]; then \
		echo "ERROR: WO_API_KEY is not set. Add it to $(ENV_FILE)"; \
		exit 1; \
	fi

# -----------------------------
# Setup
# -----------------------------
.PHONY: install
install: check
	@if [ -d "$(VENVDIR_CLEAN)" ]; then \
		echo "Venv already exists: $(VENVDIR_CLEAN)"; \
	else \
		echo "Creating venv at $(VENVDIR_CLEAN) using $(PYTHON)"; \
		$(PYTHON) -m venv $(VENVDIR_CLEAN); \
	fi

	@if [ ! -x "$(PIP)" ]; then \
	echo "ERROR: pip not found in venv ($(PIP))"; \
	exit 1; \
	fi

	@echo "Upgrading pip/setuptools/wheel"
	@$(PIP) install --upgrade pip setuptools wheel

	@echo "Installing ibm-watsonx-orchestrate==$(WXO_VERSION)"
	@$(PIP) install ibm-watsonx-orchestrate==$(WXO_VERSION)

	@echo "Installing test dependencies (pytest)"
	@$(PIP) install -U pytest

	@if [ -f "tools/requirements.txt" ]; then \
		echo "Installing tools requirements (tools/requirements.txt)"; \
		$(PIP) install -r tools/requirements.txt; \
	else \
		echo "No tools/requirements.txt found. Skipping."; \
	fi

	@echo "Installing shell completion"
	@$(ORCH) --install-completion
	@echo ""
	@echo "✅ Done."
	@echo "VS Code: Cmd+Shift+P -> Python: Select Interpreter -> $$(pwd)/$(VENVDIR_CLEAN)/bin/python"

.PHONY: upgrade
upgrade: _require_venv
	@if [ ! -x "$(PIP)" ]; then \
		echo "ERROR: pip not found in venv ($(PIP)). Run: make install"; \
		exit 1; \
	fi
	@echo "Upgrading ibm-watsonx-orchestrate to $(WXO_VERSION)"
	@$(PIP) install --upgrade ibm-watsonx-orchestrate==$(WXO_VERSION)
	@echo "Orchestrate version now:"
	@$(ORCH) --version 2>/dev/null | head -n 1 || true


.PHONY: cleanup
cleanup:
	@if [ -z "$(VENVDIR_CLEAN)" ] || [ "$(VENVDIR_CLEAN)" = "/" ] || [ "$(VENVDIR_CLEAN)" = "." ]; then \
		echo "ERROR: Refusing to delete VENVDIR='$(VENVDIR_CLEAN)'"; \
		exit 1; \
	fi
	@if [ ! -d "$(VENVDIR_CLEAN)" ]; then \
		echo "No venv to remove at $(VENVDIR_CLEAN)"; \
		exit 0; \
	fi
	@echo "Removing venv $(VENVDIR_CLEAN)"
	@rm -rf "$(VENVDIR_CLEAN)"

.PHONY: server_stop_safe
server_stop_safe:
	@if [ -x "$(ORCH)" ]; then \
		echo "Stopping local server (if running)"; \
		$(ORCH) server stop >/dev/null 2>&1 || true; \
	else \
		echo "orchestrate CLI not installed yet; skip stop"; \
	fi

.PHONY: reinstall
reinstall: server_stop_safe cleanup install
	@echo "✅ Reinstall complete."

.PHONY: bootstrap
bootstrap: doctor init-structure install bin-orchestrate start chat
	@echo "✅ Bootstrap complete."

# -----------------------------
# Project-local CLI wrapper
# -----------------------------
.PHONY: bin-orchestrate
bin-orchestrate: _require_venv
	@mkdir -p bin
	@printf '%s\n' \
'#!/usr/bin/env bash' \
'set -euo pipefail' \
'ROOT="$$(cd "$$(dirname "$${BASH_SOURCE[0]}")/.." && pwd)"' \
'exec "$$ROOT/venv/bin/orchestrate" "$$@"' \
> bin/orchestrate
	@chmod +x bin/orchestrate
	@echo "✅ Created ./bin/orchestrate"

.PHONY: use
use:
	@printf '%s\n' 'case ":$$PATH:" in *":'"$$(pwd)"'/bin:"*) ;; *) export PATH="'"$$(pwd)"'/bin:$$PATH" ;; esac'

# -----------------------------
# Local server
# -----------------------------
.PHONY: server_start start
server_start: _require_orch _require_env
	@echo "Starting local server (if not already running)"; \
	LOG_FILE=/tmp/orchestrate_start_$$$$.log; \
	$(ORCH) server start --env-file $(ENV_FILE) $(OBSERVABILITY_TOOL) $(OPTIONAL_TOOLS) 2>&1 | tee $$LOG_FILE; \
	if grep -q "Orchestrate services initialized successfully" $$LOG_FILE; then \
		echo "✅ Server started (validated)"; \
	else \
		echo "❌ Server did NOT fully start (no success marker found)."; \
		echo "Last 30 log lines:"; \
		tail -n 30 $$LOG_FILE || true; \
		echo "   Check errors above or run: make logs"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "Extracting UI INFO lines containing URLs..."; \
	grep '\[INFO\]' $$LOG_FILE \
		| grep -E 'https?://[^ ]+' \
		| sed -E 's/\x1B\[[0-9;]*[[:alpha:]]//g' \
		| sed -E 's/^\[INFO\][[:space:]]*-[[:space:]]*//' \
		> endpoints.ui.log || true; \
	if [ -s endpoints.ui.log ]; then \
		echo "✅ UI endpoints detected:"; \
		cat endpoints.ui.log; \
	else \
		echo "ℹ️  No UI endpoints detected in startup logs."; \
	fi
start: server_start

.PHONY: server_logs logs
server_logs: _require_orch
	@echo "Showing server logs"
	@$(ORCH) server logs
logs: server_logs

.PHONY: logs-follow
logs-follow: _require_orch
	@echo "Following server logs every $(LOGS_POLL)s (Ctrl+C to stop)"
	@while true; do \
		$(ORCH) server logs; \
		sleep $(LOGS_POLL); \
	done

.PHONY: status
status: _require_orch
	@echo "Checking local server status (best-effort)..."
	@$(ORCH) server logs >/dev/null 2>&1 && \
		echo "LIKELY RUNNING (logs reachable)" || \
		echo "LIKELY STOPPED (logs not reachable)"


.PHONY: server_stop stop
server_stop: _require_orch
	@echo "Stopping local server (if running)"
	@$(ORCH) server stop || \
		echo "Server may already be stopped. Continuing."
stop: server_stop

.PHONY: server_restart restart
server_restart: server_stop server_start
restart: server_restart

.PHONY: server_reset reset
server_reset: _require_orch server_stop
	@echo "⚠️  This will RESET the local Orchestrate server."
	@echo "It may delete containers, volumes, and local state."
	@echo "To confirm, run: make reset CONFIRM=YES"
	@if [ "$${CONFIRM:-NO}" != "YES" ]; then \
		echo "Not confirmed. Aborting."; \
		exit 1; \
	fi
	@echo "Resetting local server..."
	@$(ORCH) server reset || \
		echo "Server reset may have already been applied. Continuing."
reset: server_reset

.PHONY: prune-cpd
prune-cpd: _require_orch _require_env
	@echo "Pruning docker images (cpd only) (best-effort)"
	@$(ORCH) server images prune --env-file $(ENV_FILE) || \
		echo "WARN: prune failed (possibly nothing to prune, or server not ready)."

# Destructive: require explicit confirmation
.PHONY: purge
purge: _require_orch
	@echo "⚠️  This will DELETE the underlying VM and ALL its data."
	@echo "To confirm, run: make purge CONFIRM=YES"
	@if [ "$${CONFIRM:-NO}" != "YES" ]; then \
		echo "Not confirmed. Aborting."; \
		exit 1; \
	fi
	@echo "Stopping server (best-effort) before purge..."
	@$(ORCH) server stop >/dev/null 2>&1 || true
	@echo "Purging..."
	@$(ORCH) server purge

# -----------------------------
# Chat / Copilot
# -----------------------------
.PHONY: chat copilot
chat: _require_orch _require_env
	@echo "Launching chat"
	@$(ORCH) chat start --env-file $(ENV_FILE)

copilot: _require_orch _require_env
	@echo "Launching copilot"
	@$(ORCH) copilot start --env-file $(ENV_FILE)

# -----------------------------
# Project structure
# -----------------------------
.PHONY: init-structure
init-structure:
	@echo "Initializing project folder structure..."
	@mkdir -p \
		agents \
		tools \
		connections \
		knowledge-bases \
		toolkits \
		models
	@echo "✅ Folder structure created (or already exists)"

# -----------------------------
# Project actions
# -----------------------------
.PHONY: deploy connections test list

deploy: _require_orch _require_scripts_dir
	@echo "Deploying tools and agents"
	@cd scripts && ./deploy.sh

connections: _require_orch _require_scripts_dir
	@echo "Deploying connections"
	@cd scripts && ./create_connections.sh

test: _require_venv
	@echo "Running tests"
	@$(PYTEST)

list: _require_orch
	@echo "Listing connections, tools and agents"
	@$(ORCH) connections list
	@$(SLEEP)
	@$(ORCH) tools list
	@$(SLEEP)
	@$(ORCH) agents list

# -----------------------------
# SaaS env management
# -----------------------------
.PHONY: register_saas activate_saas activate_local register saas local

register_saas: _require_orch _require_env _require_wo_instance
	@echo "Register SaaS environment as $(WXO_SAAS_ENV) (WO_INSTANCE is set)"
	@$(ORCH) env add --name $(WXO_SAAS_ENV) --url "$$WO_INSTANCE"

activate_saas: _require_orch _require_env _require_wo_api_key
	@echo "Activate SaaS environment $(WXO_SAAS_ENV) (WO_API_KEY is set)"
	@$(ORCH) env activate $(WXO_SAAS_ENV) --api-key="$$WO_API_KEY"

activate_local: _require_orch
	@echo "Activate Local environment"
	@$(ORCH) env activate local

register: register_saas
saas: activate_saas
local: activate_local

# -----------------------------
# Doctor (non-destructive checks)
# -----------------------------
.PHONY: doctor
.SILENT: doctor
doctor:
	echo "== Orchestrate ADK Doctor =="
	echo "Project: $$(pwd)"
	echo ""
	FAIL=0; WARN=0; \
	echo "[1/6] Python"; \
	if command -v $(PYTHON) >/dev/null 2>&1; then \
		echo "  ✅ Found: $$(command -v $(PYTHON))"; \
		echo "  ✅ Version: $$($(PYTHON) --version)"; \
		if $(PYTHON) -c 'import sys; raise SystemExit(0 if sys.version_info[:2]==(3,12) else 1)'; then :; \
		else echo "  ❌ Expected Python 3.12"; FAIL=1; fi; \
	else \
		echo "  ❌ $(PYTHON) not found"; FAIL=1; \
	fi; \
	echo ""; \
	echo "[2/6] Env file"; \
	if [ -f "$(ENV_FILE)" ]; then \
		echo "  ✅ Present: $(ENV_FILE)"; \
	else \
		echo "  ❌ Missing: $(ENV_FILE)"; \
		echo "     Create it or set ENV_FILE=..."; \
		FAIL=1; \
	fi; \
	echo ""; \
	echo "[3/6] Virtualenv"; \
	if [ -x "$(PY)" ]; then \
		echo "  ✅ Venv python: $(PY) ($$($(PY) --version))"; \
	else \
		echo "  ⚠️  Venv python not found at: $(PY)"; \
		echo "     Run: make install"; \
		WARN=1; \
	fi; \
	if [ -x "$(PIP)" ]; then \
		echo "  ✅ Venv pip: $(PIP) ($$($(PIP) --version | head -n 1))"; \
	else \
		echo "  ⚠️  Venv pip not found at: $(PIP)"; \
		WARN=1; \
	fi; \
	echo ""; \
	echo "[4/6] Orchestrate CLI"; \
	if [ -x "$(ORCH)" ]; then \
		echo "  ✅ Found: $(ORCH)"; \
		VER=$$($(ORCH) --version 2>/dev/null | head -n 1 || true); \
		if [ -n "$$VER" ]; then echo "  ✅ Version: $$VER"; else echo "  ⚠️  Version: unavailable"; WARN=1; fi; \
	else \
		echo "  ⚠️  Not installed in venv: $(ORCH)"; \
		echo "     Run: make install"; \
		WARN=1; \
	fi; \
	echo ""; \
	echo "[5/6] Key variables in $(ENV_FILE) (presence only)"; \
	if [ -f "$(ENV_FILE)" ]; then \
		for v in WO_INSTANCE_ALIAS WO_INSTANCE WO_API_KEY; do \
			if grep -Eq "^[[:space:]]*$$v=" "$(ENV_FILE)"; then \
				val=$$(grep -E "^[[:space:]]*$$v=" "$(ENV_FILE)" | tail -n 1 | cut -d= -f2-); \
				if [ -n "$$val" ]; then \
					if [ "$$v" = "WO_API_KEY" ]; then echo "  ✅ $$v is set (hidden)"; else echo "  ✅ $$v is set"; fi; \
				else \
					echo "  ⚠️  $$v is empty"; WARN=1; \
				fi; \
			else \
				echo "  ⚠️  $$v not found"; WARN=1; \
			fi; \
		done; \
	else \
		echo "  (skipped: env file missing)"; \
	fi; \
	echo ""; \
	echo "[6/6] Local server & Registry (best-effort)"; \
	if [ -x "$(ORCH)" ]; then \
		if printf '%s\n' \
			'import subprocess, sys' \
			'cmd = ["./venv/bin/orchestrate", "server", "logs"]' \
			'try:' \
			'    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=2, check=False)' \
			'    sys.exit(0)' \
			'except subprocess.TimeoutExpired:' \
			'    sys.exit(0)' \
			'except Exception:' \
			'    sys.exit(1)' \
			| $(PY) - >/dev/null 2>&1; then \
				echo "  ✅ Local server reachable (logs command responded/hangs as expected)"; \
		else \
				echo "  ⚠️  Local server not reachable (logs command failed)"; \
				echo "     Try: make start   then: make logs"; \
				WARN=1; \
		fi; \
	else \
		echo "  ⚠️  Orchestrate CLI missing; skipping local server check"; \
		WARN=1; \
	fi; \
	if command -v curl >/dev/null 2>&1; then \
		HTTP=$$(curl -s -o /dev/null -w "%{http_code}" "https://registry.eu-central-1.dl.watson-orchestrate.ibm.com/v2/" || true); \
		if [ "$$HTTP" = "401" ] || [ "$$HTTP" = "200" ]; then \
			echo "  ✅ Registry reachable (HTTP $$HTTP)"; \
		elif [ -n "$$HTTP" ]; then \
			echo "  ⚠️  Registry check returned HTTP $$HTTP"; WARN=1; \
		else \
			echo "  ⚠️  Registry check failed (curl error)"; WARN=1; \
		fi; \
	else \
		echo "  ⚠️  curl not found; skipping registry check"; \
		WARN=1; \
	fi; \
	echo ""; \
	if [ "$$FAIL" -ne 0 ]; then \
		echo "Doctor result: ❌ FAIL"; exit 1; \
	elif [ "$$WARN" -ne 0 ]; then \
		echo "Doctor result: ⚠️  OK with warnings"; exit 0; \
	else \
		echo "Doctor result: ✅ OK"; exit 0; \
	fi




