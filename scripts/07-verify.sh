#!/usr/bin/env bash
# 07-verify.sh — Full environment verification
source "$(dirname "$0")/common.sh"

header "DevOps Project 2026 — Environment Verification"

PASS=0
FAIL=0
WARN=0

check() {
  local label="$1"
  local cmd="$2"
  local result

  if result=$(eval "$cmd" 2>/dev/null) && [ -n "$result" ]; then
    printf "${GREEN}[PASS]${NC}  %-22s %s\n" "$label" "$result"
    ((PASS++))
  else
    printf "${RED}[FAIL]${NC}  %-22s %s\n" "$label" "not found"
    ((FAIL++))
  fi
}

check_optional() {
  local label="$1"
  local cmd="$2"
  local result

  if result=$(eval "$cmd" 2>/dev/null) && [ -n "$result" ]; then
    printf "${GREEN}[PASS]${NC}  %-22s %s\n" "$label" "$result"
    ((PASS++))
  else
    printf "${YELLOW}[SKIP]${NC}  %-22s %s\n" "$label" "not installed (optional)"
    ((WARN++))
  fi
}

# ─── Core Tools ──────────────────────────────────────────────────────────────
echo -e "${BOLD}Core Tools:${NC}"
check "Docker"       "docker --version | grep -oP '\d+\.\d+\.\d+' | head -1"
check "AWS CLI"      "aws --version | grep -oP 'aws-cli/[\d.]+'"
check "Terraform"    "terraform version -json | jq -r '.terraform_version'"
check "Terragrunt"   "terragrunt --version | grep -oP 'v?[\d.]+' | head -1"
check "kubectl"      "kubectl version --client -o json | jq -r '.clientVersion.gitVersion'"
check "Helm"         "helm version --short"
echo ""

# ─── Kubernetes Tools ────────────────────────────────────────────────────────
echo -e "${BOLD}Kubernetes Ecosystem:${NC}"
check "kind"         "kind version | grep -oP 'v?[\d.]+'"
check "eksctl"       "eksctl version"
check "kubeconform"  "kubeconform -v"
check "pluto"        "pluto version | grep -oP 'v?[\d.]+' | head -1"
echo ""

# ─── Security & Linting ─────────────────────────────────────────────────────
echo -e "${BOLD}Security & Linting:${NC}"
check "Trivy"          "trivy version | grep -oP 'Version:\s*[\d.]+'"
check "tflint"         "tflint --version | grep -oP '[\d.]+' | head -1"
check "terraform-docs" "terraform-docs --version | grep -oP '[\d.]+' | head -1"
echo ""

# ─── Productivity ────────────────────────────────────────────────────────────
echo -e "${BOLD}Productivity & Debugging:${NC}"
check_optional "k9s"     "k9s version --short 2>&1 | head -1"
check_optional "stern"   "stern --version | head -1"
check_optional "kubectx" "kubectx --version 2>&1 | head -1"
check_optional "dive"    "dive version 2>&1 | head -1"
check_optional "act"     "act --version"
echo ""

# ─── Environment Variables ───────────────────────────────────────────────────
echo -e "${BOLD}Environment:${NC}"

for var in AWS_PROFILE AWS_DEFAULT_REGION TF_PLUGIN_CACHE_DIR EDITOR; do
  val="${!var:-}"
  if [ -n "$val" ]; then
    printf "${GREEN}[PASS]${NC}  %-22s %s\n" "\$$var" "$val"
    ((PASS++))
  else
    printf "${YELLOW}[SKIP]${NC}  %-22s %s\n" "\$$var" "not set (source your shell rc)"
    ((WARN++))
  fi
done

# Check Terraform plugin cache dir exists
if [ -d "${TF_PLUGIN_CACHE_DIR:-$HOME/.terraform.d/plugin-cache}" ]; then
  printf "${GREEN}[PASS]${NC}  %-22s %s\n" "TF plugin cache" "directory exists"
  ((PASS++))
else
  printf "${RED}[FAIL]${NC}  %-22s %s\n" "TF plugin cache" "directory missing"
  ((FAIL++))
fi
echo ""

# ─── Connectivity ────────────────────────────────────────────────────────────
echo -e "${BOLD}Connectivity:${NC}"

# AWS authentication
if aws sts get-caller-identity --profile npo-aws &>/dev/null; then
  local_account=$(aws sts get-caller-identity --profile npo-aws --query 'Account' --output text 2>/dev/null)
  printf "${GREEN}[PASS]${NC}  %-22s %s\n" "AWS Auth" "account ${local_account}"
  ((PASS++))
else
  printf "${YELLOW}[SKIP]${NC}  %-22s %s\n" "AWS Auth" "not authenticated (run: aws sso login --profile npo-aws)"
  ((WARN++))
fi

# GitHub SSH
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  printf "${GREEN}[PASS]${NC}  %-22s %s\n" "GitHub SSH" "authenticated"
  ((PASS++))
else
  printf "${YELLOW}[SKIP]${NC}  %-22s %s\n" "GitHub SSH" "not configured or not authenticated"
  ((WARN++))
fi

# Docker daemon
if docker info &>/dev/null; then
  printf "${GREEN}[PASS]${NC}  %-22s %s\n" "Docker daemon" "running"
  ((PASS++))
else
  printf "${YELLOW}[SKIP]${NC}  %-22s %s\n" "Docker daemon" "not running (start Docker or re-login for group)"
  ((WARN++))
fi
echo ""

# ─── VS Code Extensions ─────────────────────────────────────────────────────
if cmd_exists code; then
  echo -e "${BOLD}VS Code Extensions:${NC}"
  INSTALLED=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
  ESSENTIAL_EXTS=(
    "hashicorp.terraform"
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "redhat.vscode-yaml"
    "github.vscode-github-actions"
    "tim-koehler.helm-intellisense"
  )
  for ext in "${ESSENTIAL_EXTS[@]}"; do
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    if echo "$INSTALLED" | grep -q "^${ext_lower}$"; then
      printf "${GREEN}[PASS]${NC}  %-22s %s\n" "Extension" "$ext"
      ((PASS++))
    else
      printf "${RED}[FAIL]${NC}  %-22s %s\n" "Extension" "$ext (missing)"
      ((FAIL++))
    fi
  done
  echo ""
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
header "Summary"
echo -e "  ${GREEN}Passed:${NC}   $PASS"
echo -e "  ${RED}Failed:${NC}   $FAIL"
echo -e "  ${YELLOW}Skipped:${NC}  $WARN"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}Environment is ready! You can start building.${NC}"
  exit 0
else
  echo -e "${RED}${BOLD}$FAIL check(s) failed. Fix the issues above and re-run.${NC}"
  exit 1
fi
