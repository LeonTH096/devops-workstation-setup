#!/usr/bin/env bash
# 06-shell-config.sh — Environment variables, aliases, completions, plugin cache
source "$(dirname "$0")/common.sh"
check_not_root

header "Shell Configuration"

# Detect shell config file
if [ -n "${ZSH_VERSION:-}" ] || [ -f "$HOME/.zshrc" ]; then
  SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_RC="$HOME/.bashrc"
else
  SHELL_RC="$HOME/.bashrc"
fi

info "Configuring shell: $SHELL_RC"

# Marker to identify our managed block
MARKER_START="# >>> devops-project-2026 >>>"
MARKER_END="# <<< devops-project-2026 <<<"

CONFIG_BLOCK=$(cat <<'BLOCK'
# >>> devops-project-2026 >>>
# Managed by devops-workstation-setup — do not edit manually

# AWS
export AWS_PROFILE=npo-aws
export AWS_DEFAULT_REGION=eu-west-1

# Terraform plugin cache (avoid re-downloading providers)
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

# Editor
export EDITOR="code --wait"
export KUBE_EDITOR="code --wait"

# Aliases
alias tf="terraform"
alias tg="terragrunt"
alias k="kubectl"
alias h="helm"
alias d="docker"
alias bat="batcat"

# kubectl autocompletion
if command -v kubectl &>/dev/null; then
  source <(kubectl completion $(basename $SHELL) 2>/dev/null) 2>/dev/null || true
fi

# Helm autocompletion
if command -v helm &>/dev/null; then
  source <(helm completion $(basename $SHELL) 2>/dev/null) 2>/dev/null || true
fi

# kubectl alias completion (zsh)
if [ -n "${ZSH_VERSION:-}" ] && command -v kubectl &>/dev/null; then
  compdef __start_kubectl k 2>/dev/null || true
fi

# <<< devops-project-2026 <<<
BLOCK
)

# Check if block already exists
if grep -q "$MARKER_START" "$SHELL_RC" 2>/dev/null; then
  info "Config block found — replacing with latest version..."
  # Remove old block and replace
  tmpfile=$(mktemp)
  awk "
    /$MARKER_START/{skip=1; next}
    /$MARKER_END/{skip=0; next}
    !skip{print}
  " "$SHELL_RC" > "$tmpfile"
  echo "$CONFIG_BLOCK" >> "$tmpfile"
  mv "$tmpfile" "$SHELL_RC"
  success "Shell config block updated in $SHELL_RC"
else
  info "Adding config block to $SHELL_RC..."
  echo "" >> "$SHELL_RC"
  echo "$CONFIG_BLOCK" >> "$SHELL_RC"
  success "Shell config block added to $SHELL_RC"
fi

# Create Terraform plugin cache directory
mkdir -p "$HOME/.terraform.d/plugin-cache"
success "Terraform plugin cache dir created"

# Create .kube directory
mkdir -p "$HOME/.kube"
success "~/.kube directory ensured"

echo ""
warn "Run 'source $SHELL_RC' or open a new terminal for changes to take effect"
