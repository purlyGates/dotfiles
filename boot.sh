#!/usr/bin/env bash
# boot.sh - full system bootstrap orchestrator
# Run from a fresh Arch install after `archinstall`:
#   ./boot.sh              # full run
#   ./boot.sh packaging    # only one phase group

set -eEo pipefail

export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_INSTALL="$DOTFILES/install"
export PATH="$DOTFILES/bin:$PATH"

# shellcheck disable=SC1091
source "$DOTFILES_INSTALL/helpers/all.sh"

PHASES=(preflight packaging config post-install)

run_phase() {
    local phase=$1
    local script="$DOTFILES_INSTALL/$phase/all.sh"
    [ -f "$script" ] || die "unknown phase: $phase"
    log "==== phase: $phase ===="
    # shellcheck disable=SC1090
    source "$script"
}

if [ $# -eq 0 ]; then
    for p in "${PHASES[@]}"; do run_phase "$p"; done
else
    for p in "$@"; do run_phase "$p"; done
fi
