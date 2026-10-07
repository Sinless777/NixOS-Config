#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
HOST="${HOST:-desktop}"
ACTION="switch"
DRY_RUN=0
NO_REEXEC=0
BUILD_MAX_JOBS="${BUILD_MAX_JOBS:-4}"
BUILD_CORES="${BUILD_CORES:-4}"

usage() {
  cat <<'EOF'
Usage: ./scripts/apply.sh [switch|test|boot|build] [--host HOST] [--dry-run] [--no-reexec]

  switch     Build, activate, and make the configuration the boot default.
  test       Build and activate without changing the boot default.
  boot       Build and make the configuration the boot default for next boot.
  build      Build without activating; creates result in the repository.
  --host     Select the flake host (default: HOST environment variable or desktop).
  --dry-run  Print the command without building or activating anything.
  --no-reexec Use the installed rebuild tool for compatibility during upgrades.
  --help     Show this help.

Build limits default to one job and four cores per job. Override through
BUILD_MAX_JOBS and BUILD_CORES (positive integers).

Examples:
  ./scripts/apply.sh
  ./scripts/apply.sh test --host desktop
  ./scripts/apply.sh --dry-run

Home Manager is applied as part of the NixOS configuration.
Run ./scripts/validate.sh first if you want the full validation checks.
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

action_set=0
while (( $# > 0 )); do
  case "$1" in
    switch|test|boot|build)
      (( action_set == 0 )) || die "Specify only one action"
      ACTION="$1"
      action_set=1
      shift
      ;;
    --host)
      (( $# >= 2 )) || die "--host requires a host name"
      HOST="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-reexec)
      NO_REEXEC=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) die "Unknown argument: $1 (use --help)" ;;
  esac
done

[[ "${HOST}" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]] || die "Invalid host name: ${HOST}"
for value in "$BUILD_MAX_JOBS" "$BUILD_CORES"; do
  [[ "$value" =~ ^[1-9][0-9]*$ ]] || die "BUILD_MAX_JOBS and BUILD_CORES must be positive integers"
done
[[ -f "${REPO_ROOT}/flake.nix" ]] || die "flake.nix not found"
[[ -f "${REPO_ROOT}/hosts/${HOST}/default.nix" ]] || die "Host configuration not found: ${HOST}"

cd "${REPO_ROOT}"
command_args=(nixos-rebuild "${ACTION}" --flake "path:${REPO_ROOT}#${HOST}" --show-trace
  --max-jobs "${BUILD_MAX_JOBS}" --cores "${BUILD_CORES}")

if (( NO_REEXEC )); then
  command_args+=(--no-reexec)
fi

if [[ "${ACTION}" != build ]] && (( EUID != 0 )); then
  command_args=(sudo "${command_args[@]}")
fi

printf 'Repository: %s\nHost: %s\nAction: %s\n' "${REPO_ROOT}" "${HOST}" "${ACTION}"
printf 'Command:'
printf ' %q' "${command_args[@]}"
printf '\n'

if (( DRY_RUN )); then
  exit 0
fi

command -v nixos-rebuild >/dev/null 2>&1 || die "nixos-rebuild command not found"
if [[ "${command_args[0]}" == sudo ]]; then
  command -v sudo >/dev/null 2>&1 || die "sudo command not found; run this script as root"
fi

# Replace the script so interrupts and the rebuild exit status propagate directly.
exec "${command_args[@]}"
