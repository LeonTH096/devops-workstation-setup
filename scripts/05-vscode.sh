#!/usr/bin/env bash
# 05-vscode.sh — VS Code extensions (essential + recommended)
source "$(dirname "$0")/common.sh"
check_not_root

header "VS Code Extensions"

if ! cmd_exists code; then
  warn "VS Code CLI (code) not found in PATH — skipping extensions"
  warn "Install VS Code first, then re-run: make vscode"
  exit 0
fi

# Essential extensions
ESSENTIAL=(
  "hashicorp.terraform"
  "ms-azuretools.vscode-docker"
  "ms-kubernetes-tools.vscode-kubernetes-tools"
  "redhat.vscode-yaml"
  "ms-vscode.makefile-tools"
  "github.vscode-github-actions"
  "tim-koehler.helm-intellisense"
  "signageos.signageos-vscode-sops"
)

# Recommended extensions
RECOMMENDED=(
  "eamodio.gitlens"
  "streetsidesoftware.code-spell-checker"
  "gruntfuggly.todo-tree"
  "pkief.material-icon-theme"
  "esbenp.prettier-vscode"
  "davidanson.vscode-markdownlint"
)

# Get currently installed extensions (lowercase for comparison)
INSTALLED=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')

install_extension() {
  local ext="$1"
  local ext_lower
  ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  if echo "$INSTALLED" | grep -q "^${ext_lower}$"; then
    success "$ext (already installed)"
  else
    info "Installing $ext..."
    if code --install-extension "$ext" --force &>/dev/null; then
      success "$ext installed"
    else
      error "Failed to install $ext"
    fi
  fi
}

echo -e "${BOLD}Essential:${NC}"
for ext in "${ESSENTIAL[@]}"; do
  install_extension "$ext"
done

echo ""
echo -e "${BOLD}Recommended:${NC}"
for ext in "${RECOMMENDED[@]}"; do
  install_extension "$ext"
done

echo ""
success "VS Code extensions configured."
