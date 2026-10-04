#!/usr/bin/env bash
set -Eeuo pipefail

# =====================================================================
# validate.sh — validate the NixOS / Home Manager configuration
# ---------------------------------------------------------------------
# This script performs non-destructive validation only.
#
# It does NOT run:
#
#   nixos-rebuild switch
#
# Validation stages:
#
#   1. Repository sanity
#   2. Required file checks
#   3. Nix syntax parsing
#   4. Nix formatting verification
#   5. Flake metadata evaluation
#   6. nix flake check
#   7. NixOS configuration evaluation
#   8. Home Manager configuration evaluation
#   9. Full NixOS build
# =====================================================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

HOST="${HOST:-desktop}"
USER_NAME="${USER_NAME:-sinless777}"

FLAKE_PATH="path:${REPO_ROOT}"
FLAKE_REF="${FLAKE_PATH}#nixosConfigurations.${HOST}"

# ---------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------

if [[ -t 1 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  BLUE=$'\033[0;34m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  RESET=""
fi

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------

info() {
  printf '%s==>%s %s\n' "${BLUE}${BOLD}" "${RESET}" "$*"
}

success() {
  printf '%s✔%s %s\n' "${GREEN}" "${RESET}" "$*"
}

warn() {
  printf '%s⚠%s %s\n' "${YELLOW}" "${RESET}" "$*" >&2
}

die() {
  printf '%s✘%s %s\n' "${RED}" "${RESET}" "$*" >&2
  exit 1
}

run() {
  info "$*"
  "$@"
}

section() {
  printf '\n%s%s%s\n' "${BOLD}" "$*" "${RESET}"
}

# ---------------------------------------------------------------------
# Cleanup / failure reporting
# ---------------------------------------------------------------------

CURRENT_STAGE="startup"

on_error() {
  local exit_code=$?

  printf '\n%s✘ Validation failed%s\n' "${RED}${BOLD}" "${RESET}" >&2
  printf 'Stage: %s\n' "${CURRENT_STAGE}" >&2
  printf 'Exit code: %s\n' "${exit_code}" >&2

  exit "${exit_code}"
}

trap on_error ERR

# ---------------------------------------------------------------------
# Enter repository
# ---------------------------------------------------------------------

cd "${REPO_ROOT}"

section "SinLess NixOS Configuration Validator"

printf 'Repository : %s\n' "${REPO_ROOT}"
printf 'Host       : %s\n' "${HOST}"
printf 'User       : %s\n' "${USER_NAME}"
printf '\n'

# =====================================================================
# 1. Repository sanity
# =====================================================================

CURRENT_STAGE="repository sanity"

section "1. Repository sanity"

[[ -f flake.nix ]] || die "flake.nix not found"
[[ -d hosts ]] || die "hosts/ directory not found"
[[ -d modules ]] || die "modules/ directory not found"
[[ -d profiles ]] || die "profiles/ directory not found"
[[ -d home ]] || die "home/ directory not found"

success "Repository structure exists"

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ -n "$(git status --porcelain)" ]]; then
    warn "Git working tree has uncommitted changes"
  else
    success "Git working tree is clean"
  fi
fi

# =====================================================================
# 2. Required files
# =====================================================================

CURRENT_STAGE="required files"

section "2. Required files"

required_files=(
  "flake.nix"

  "hosts/${HOST}/default.nix"
  "hosts/${HOST}/hardware-configuration.nix"
  "hosts/${HOST}/hardware.nix"
  "hosts/${HOST}/disks.nix"
  "hosts/${HOST}/networking.nix"

  "profiles/workstation.nix"
  "profiles/development.nix"
  "profiles/ai.nix"
  "profiles/gaming.nix"
  "profiles/hardened.nix"
  "profiles/server.nix"

  "home/${USER_NAME}/default.nix"
  "home/${USER_NAME}/aliases.nix"
  "home/${USER_NAME}/codex.nix"
  "home/${USER_NAME}/fonts.nix"
  "home/${USER_NAME}/git.nix"
  "home/${USER_NAME}/gnome.nix"
  "home/${USER_NAME}/packages.nix"
  "home/${USER_NAME}/shell.nix"
  "home/${USER_NAME}/vscode.nix"
  "home/${USER_NAME}/zsh.nix"
)

missing=0

for file in "${required_files[@]}"; do
  if [[ -f "${file}" ]]; then
    printf '  ✔ %s\n' "${file}"
  else
    printf '  ✘ %s\n' "${file}" >&2
    missing=1
  fi
done

if (( missing != 0 )); then
  die "One or more required files are missing"
fi

success "Required files found"

# =====================================================================
# 3. Basic Nix syntax parsing
# =====================================================================

CURRENT_STAGE="Nix syntax parsing"

section "3. Nix syntax"

command -v nix >/dev/null 2>&1 || die "nix command not found"

mapfile -t nix_files < <(
  find . \
    -type f \
    -name '*.nix' \
    -not -path './.git/*' \
    -not -path './result*' \
    -print |
    sort
)

if (( ${#nix_files[@]} == 0 )); then
  die "No .nix files found"
fi

for file in "${nix_files[@]}"; do
  printf '  parsing %s\n' "${file}"
  nix-instantiate --parse "${file}" >/dev/null
done

success "All Nix files parse successfully"

# =====================================================================
# 4. Formatting
# =====================================================================

CURRENT_STAGE="format validation"

section "4. Formatting"

if command -v nixfmt >/dev/null 2>&1; then
  NIXFMT="$(command -v nixfmt)"
else
  info "Loading the formatter from the flake"
  nix_system="$(nix --extra-experimental-features 'nix-command flakes' eval --impure --raw --expr builtins.currentSystem)"
  formatter_path="$(nix --extra-experimental-features 'nix-command flakes' build \
    "${FLAKE_PATH}#formatter.${nix_system}" --no-link --no-write-lock-file --print-out-paths)"
  NIXFMT="${formatter_path}/bin/nixfmt"
fi

[[ -x "${NIXFMT}" ]] || die "Flake formatter is not executable: ${NIXFMT}"

formatting_failed=0

for file in "${nix_files[@]}"; do
  if ! "${NIXFMT}" --check "${file}" >/dev/null 2>&1; then
    warn "Formatting differs: ${file}"
    formatting_failed=1
  fi
done

if (( formatting_failed != 0 )); then
  warn "Some files are not formatted with nixfmt"
  warn "Run: nix fmt"
else
  success "Nix formatting looks good"
fi

# =====================================================================
# 5. Flake metadata
# =====================================================================

CURRENT_STAGE="flake metadata"

section "5. Flake metadata"

run nix \
  --extra-experimental-features "nix-command flakes" \
  flake metadata \
  --no-write-lock-file \
  "${FLAKE_PATH}"

success "Flake metadata evaluates"

# =====================================================================
# 6. Flake check
# =====================================================================

CURRENT_STAGE="nix flake check"

section "6. nix flake check"

run nix \
  --extra-experimental-features "nix-command flakes" \
  flake check \
  --show-trace \
  --no-build \
  --no-write-lock-file \
  "${FLAKE_PATH}"

success "Flake checks passed"

# =====================================================================
# 7. NixOS configuration evaluation
# =====================================================================

CURRENT_STAGE="NixOS evaluation"

section "7. NixOS evaluation"

run nix \
  --extra-experimental-features "nix-command flakes" \
  eval \
  "${FLAKE_REF}.config.system.build.toplevel.drvPath" \
  --raw \
  --show-trace \
  >/dev/null

success "NixOS host '${HOST}' evaluates"

# ---------------------------------------------------------------------
# Evaluate some critical values as smoke tests
# ---------------------------------------------------------------------

hostname="$(
  nix \
    --extra-experimental-features "nix-command flakes" \
    eval \
    "${FLAKE_REF}.config.networking.hostName" \
    --raw
)"

state_version="$(
  nix \
    --extra-experimental-features "nix-command flakes" \
    eval \
    "${FLAKE_REF}.config.system.stateVersion" \
    --raw
)"

printf '  Hostname     : %s\n' "${hostname}"
printf '  State version: %s\n' "${state_version}"

if [[ "${hostname}" != "${HOST}" ]]; then
  warn "Flake host '${HOST}' evaluates to hostname '${hostname}'"
fi

# =====================================================================
# 8. Home Manager evaluation
# =====================================================================

CURRENT_STAGE="Home Manager evaluation"

section "8. Home Manager evaluation"

HM_ATTR="${FLAKE_REF}.config.home-manager.users.${USER_NAME}.home.activationPackage.drvPath"

run nix \
  --extra-experimental-features "nix-command flakes" \
  eval \
  "${HM_ATTR}" \
  --raw \
  --show-trace \
  >/dev/null

success "Home Manager configuration for '${USER_NAME}' evaluates"

# =====================================================================
# 9. Full system build
# =====================================================================

CURRENT_STAGE="full NixOS build"

section "9. Full system build"

info "Building host without activating it"

run nix \
  --extra-experimental-features "nix-command flakes" \
  build \
  "${FLAKE_REF}.config.system.build.toplevel" \
  --show-trace \
  --print-build-logs \
  --no-link

success "Full NixOS system builds successfully"

# =====================================================================
# Complete
# =====================================================================

CURRENT_STAGE="complete"

printf '\n%s%sValidation complete ✔%s\n\n' \
  "${GREEN}" \
  "${BOLD}" \
  "${RESET}"

printf 'Validated:\n'
printf '  Host         : %s\n' "${HOST}"
printf '  User         : %s\n' "${USER_NAME}"
printf '  Nix files    : %s\n' "${#nix_files[@]}"
printf '  Flake        : passed\n'
printf '  NixOS eval   : passed\n'
printf '  Home Manager : passed\n'
printf '  System build : passed\n'
