SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -Eeuo pipefail -c

REPO_NAME := policy-enforcement-foundations
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.0.0")

EXAMPLE ?= examples/input.sample.json
OUT_DIR ?= out

.DEFAULT_GOAL := help

help: ## Show targets
	@echo "$(REPO_NAME) v$(VERSION)"
	@echo
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS=":.*?## "}; {printf "  %-16s %s\n", $$1, $$2}'

check-tools: ## Check required tools
	@command -v docker >/dev/null || (echo "ERROR: docker is required" && exit 1)
	@command -v python3 >/dev/null || (echo "ERROR: python3 is required" && exit 1)
	@docker info >/dev/null || (echo "ERROR: docker daemon not accessible" && exit 1)
	@echo "OK: tools available"

eval: check-tools ## Evaluate policy (EXAMPLE=path.json)
	@./scripts/eval_policy.sh "$(EXAMPLE)" "$(OUT_DIR)"
	@echo "Artifacts in $(OUT_DIR)/"

gate: check-tools ## Enforce policy gate (fails if denied)
	@./scripts/gate.sh "$(EXAMPLE)" "$(OUT_DIR)"

clean: ## Remove output artifacts
	@rm -rf "$(OUT_DIR)"
	@echo "Cleaned $(OUT_DIR)/"

