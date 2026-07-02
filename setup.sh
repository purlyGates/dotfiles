#!/usr/bin/env bash
# ~/dotfiles/setup.sh — stow dotfile packages
set -euo pipefail
cd "$(dirname "$0")"

usage() {
  echo "usage: ./setup.sh [all|<package>]"
  echo
  echo "packages in config/ (→ ~/.config):"
  (cd config 2>/dev/null && ls -d */ 2>/dev/null | sed 's|/||;s|^|  |') || true
  echo "packages in home/ (→ ~):"
  (cd home   2>/dev/null && ls -d */ 2>/dev/null | sed 's|/||;s|^|  |') || true
}

stow_pkg() {
  local pkg=$1
  if   [ -d "config/$pkg" ]; then (cd config && stow -R "$pkg") && echo "✓ $pkg → ~/.config/$pkg"
  elif [ -d "home/$pkg"   ]; then (cd home   && stow -R "$pkg") && echo "✓ $pkg → ~"
  else echo "✗ unknown package: $pkg" >&2; return 1
  fi
}

stow_all() {
  for d in config/*/ home/*/; do
    [ -d "$d" ] || continue
    stow_pkg "$(basename "$d")"
  done
}

case "${1:-}" in
  ""|-h|--help) usage ;;
  all)          stow_all ;;
  *)            stow_pkg "$1" ;;
esac
