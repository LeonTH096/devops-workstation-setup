SHELL := /bin/bash
.DEFAULT_GOAL := help
SCRIPTS := scripts

# ── Colors (for help target) ─────────────────────────────────────────────────
CYAN  := \033[0;36m
GREEN := \033[0;32m
BOLD  := \033[1m
NC    := \033[0m

# ── Make all scripts executable ──────────────────────────────────────────────
$(shell chmod +x $(SCRIPTS)/*.sh 2>/dev/null)

# ══════════════════════════════════════════════════════════════════════════════
#  TARGETS
# ══════════════════════════════════════════════════════════════════════════════

.PHONY: all prereqs core k8s security productivity vscode shell verify clean help

## Run complete setup (all scripts in order)
all: prereqs core k8s security productivity vscode shell verify

## Install system prerequisites (curl, git, jq, etc.)
prereqs:
	@$(SCRIPTS)/00-prerequisites.sh

## Install core tools (Docker, AWS CLI, Terraform, Terragrunt, kubectl, Helm)
core: prereqs
	@$(SCRIPTS)/01-core-tools.sh

## Install Kubernetes tools (kind, eksctl, kubeconform, pluto)
k8s: prereqs
	@$(SCRIPTS)/02-k8s-tools.sh

## Install security & linting tools (Trivy, tflint, terraform-docs)
security: prereqs
	@$(SCRIPTS)/03-security-lint.sh

## Install productivity tools (k9s, stern, kubectx, dive, act)
productivity: prereqs
	@$(SCRIPTS)/04-productivity.sh

## Install VS Code extensions
vscode:
	@$(SCRIPTS)/05-vscode.sh

## Configure shell (env vars, aliases, completions)
shell:
	@$(SCRIPTS)/06-shell-config.sh

## Verify entire environment
verify:
	@$(SCRIPTS)/07-verify.sh

## Remove temp files (does NOT uninstall tools)
clean:
	@echo "Cleaning temporary files..."
	@rm -rf /tmp/terragrunt /tmp/kubectl /tmp/k9s.deb /tmp/stern* /tmp/dive* /tmp/pluto* /tmp/kubeconform*
	@echo "Done."

## Show this help
help:
	@echo ""
	@echo -e "$(BOLD)DevOps Project 2026 — Workstation Setup$(NC)"
	@echo -e "$(CYAN)────────────────────────────────────────$(NC)"
	@echo ""
	@echo -e "$(BOLD)Usage:$(NC)"
	@echo "  make all            Run complete setup (recommended for first time)"
	@echo "  make <target>       Run a specific setup step"
	@echo "  make verify         Check everything is installed and configured"
	@echo ""
	@echo -e "$(BOLD)Targets:$(NC)"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## //' | \
		awk 'BEGIN {FS = ":"}; /^[a-zA-Z]/ {target=$$1; next} {printf "  $(GREEN)%-18s$(NC) %s\n", target, $$0}'
	@echo ""
	@echo -e "$(BOLD)Individual scripts:$(NC)"
	@echo "  make prereqs        System packages (curl, git, jq, etc.)"
	@echo "  make core           Docker, AWS CLI, Terraform, Terragrunt, kubectl, Helm"
	@echo "  make k8s            kind, eksctl, kubeconform, pluto"
	@echo "  make security       Trivy, tflint, terraform-docs"
	@echo "  make productivity   k9s, stern, kubectx, dive, act"
	@echo "  make vscode         VS Code extensions"
	@echo "  make shell          Shell aliases, env vars, completions"
	@echo "  make verify         Full environment verification"
	@echo ""
	@echo -e "$(BOLD)Examples:$(NC)"
	@echo "  make all            # First-time setup: install everything"
	@echo "  make core verify    # Update core tools and verify"
	@echo "  make verify         # Just check current state"
	@echo ""
