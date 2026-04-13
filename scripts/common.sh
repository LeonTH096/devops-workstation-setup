#!/usr/bin/env bash
# Common helper functions for all setup scripts
# Source this file: source "$(dirname "$0")/common.sh"

set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Output helpers ---
info()      { echo -e "${BLUE}[INFO]${NC}  $*"; }
success()   { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()      { echo -e "${YELLOW}[SKIP]${NC}  $*"; }
error()     { echo -e "${RED}[FAIL]${NC}  $*"; }
header()    { echo -e "\n${BOLD}${CYAN}═══ $* ═══${NC}\n"; }

# --- Check if command exists ---
cmd_exists() { command -v "$1" &>/dev/null; }

# --- Get installed version of a tool ---
get_version() {
  local tool="$1"
  case "$tool" in
    docker)       docker --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 ;;
    aws)          aws --version 2>/dev/null | grep -oP 'aws-cli/\K[\d.]+' ;;
    terraform)    terraform version -json 2>/dev/null | jq -r '.terraform_version' ;;
    terragrunt)   terragrunt --version 2>/dev/null | grep -oP 'v?\K[\d.]+' | head -1 ;;
    kubectl)      kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion' | tr -d 'v' ;;
    helm)         helm version --short 2>/dev/null | grep -oP 'v?\K[\d.]+' ;;
    kind)         kind version 2>/dev/null | grep -oP 'v?\K[\d.]+' ;;
    eksctl)       eksctl version 2>/dev/null | grep -oP '[\d.]+' | head -1 ;;
    trivy)        trivy version 2>/dev/null | grep -oP 'Version:\s*\K[\d.]+' ;;
    tflint)       tflint --version 2>/dev/null | grep -oP '[\d.]+' | head -1 ;;
    kubeconform)  kubeconform -v 2>/dev/null | grep -oP '[\d.]+' ;;
    pluto)        pluto version 2>/dev/null | grep -oP 'v?\K[\d.]+' | head -1 ;;
    k9s)          k9s version --short 2>/dev/null | grep -oP 'v?\K[\d.]+' | head -1 ;;
    stern)        stern --version 2>/dev/null | grep -oP '[\d.]+' | head -1 ;;
    kubectx)      kubectx --version 2>/dev/null 2>&1 | grep -oP '[\d.]+' | head -1 ;;
    dive)         dive version 2>/dev/null | grep -oP '[\d.]+' | head -1 ;;
    act)          act --version 2>/dev/null | grep -oP '[\d.]+' | head -1 ;;
    terraform-docs) terraform-docs --version 2>/dev/null | grep -oP '[\d.]+' | head -1 ;;
    *)            echo "unknown" ;;
  esac
}

# --- Compare semver (returns 0 if $1 >= $2) ---
version_gte() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

# --- Print tool status ---
print_status() {
  local tool="$1"
  local required="$2"
  local installed

  if cmd_exists "$tool"; then
    installed=$(get_version "$tool")
    if [ -n "$installed" ] && version_gte "$installed" "$required"; then
      success "$tool $installed (>= $required)"
      return 0
    else
      warn "$tool ${installed:-unknown} (needs >= $required)"
      return 1
    fi
  else
    error "$tool not found"
    return 1
  fi
}

# --- Ensure running as non-root (scripts use sudo where needed) ---
check_not_root() {
  if [ "$(id -u)" -eq 0 ]; then
    error "Do not run as root. Scripts use sudo where needed."
    exit 1
  fi
}

# --- Detect architecture ---
ARCH=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

export RED GREEN YELLOW BLUE CYAN BOLD NC
export ARCH OS
