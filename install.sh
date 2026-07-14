#!/usr/bin/env bash
# install.sh - remote bootstrap entrypoint
#
# Usage on a fresh Arch system:
#   bash <(curl -sL https://raw.githubusercontent.com/<user>/dotfiles/main/install.sh)
#
# Clones this repo to ~/dotfiles then runs boot.sh.

set -eEo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/aeidl/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

if ! command -v git >/dev/null; then
    sudo pacman -Sy --needed --noconfirm git
fi

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "==> cloning $REPO_URL -> $DOTFILES_DIR"
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "==> updating $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" pull --ff-only || true
fi

cd "$DOTFILES_DIR"
exec ./boot.sh "$@"
