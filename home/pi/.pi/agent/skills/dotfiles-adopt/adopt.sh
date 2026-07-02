#!/usr/bin/env bash
# adopt.sh — move a config file/dir from home into ~/dotfiles and stow it
# Usage: adopt.sh <path> [package_name]
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

die() { echo "✗ $*" >&2; exit 1; }
info() { echo "→ $*"; }
ok() { echo "✓ $*"; }

[ $# -ge 1 ] || die "usage: adopt.sh <path> [package_name]"

SRC=$(realpath -m "$1")
PKG="${2:-}"

[ -e "$SRC" ] || die "path does not exist: $SRC"
[ -L "$SRC" ] && die "path is already a symlink: $SRC → $(readlink -f "$SRC")"
[ -d "$DOTFILES" ] || die "dotfiles repo not found: $DOTFILES"
[ -x "$DOTFILES/setup.sh" ] || die "setup.sh missing/not executable: $DOTFILES/setup.sh"

# Determine root (config vs home) and relative path
if [[ "$SRC" == "$HOME/.config/"* ]]; then
  ROOT="config"
  REL="${SRC#$HOME/.config/}"          # e.g. "nvim" or "starship.toml"
elif [[ "$SRC" == "$HOME/"* ]]; then
  ROOT="home"
  REL="${SRC#$HOME/}"                  # e.g. ".zshrc" or ".ssh/config"
else
  die "path must be under \$HOME: $SRC"
fi

# Infer package name if not given
if [ -z "$PKG" ]; then
  TOP="${REL%%/*}"                     # top-level segment
  case "$ROOT" in
    config)
      # strip file extension for single-file configs (e.g. starship.toml → starship)
      if [ -f "$SRC" ] && [ "$TOP" = "$REL" ]; then
        PKG="${TOP%.*}"
      else
        PKG="$TOP"
      fi
      ;;
    home)
      # strip leading dot (.zshrc → zsh, .gitconfig → git)
      PKG="${TOP#.}"
      # strip common suffixes
      PKG="${PKG%rc}"; PKG="${PKG%config}"
      [ -n "$PKG" ] || PKG="${TOP#.}"
      ;;
  esac
fi

# Validate pkg name
[[ "$PKG" =~ ^[a-zA-Z0-9_-]+$ ]] || die "invalid package name: '$PKG'"

DEST_DIR="$DOTFILES/$ROOT/$PKG"

# Compute where inside the package the file goes (mirror layout)
case "$ROOT" in
  config)
    # target is ~/.config, so package/<REL> → ~/.config/<REL>
    DEST="$DEST_DIR/$REL"
    ;;
  home)
    # target is ~, so package/<REL> → ~/<REL>
    DEST="$DEST_DIR/$REL"
    ;;
esac

echo
info "source : $SRC"
info "root   : $ROOT/  (target: $([ "$ROOT" = config ] && echo "~/.config" || echo "~"))"
info "package: $PKG"
info "dest   : $DEST"
echo

if [ -e "$DEST" ]; then
  die "destination already exists: $DEST"
fi

# Confirm
if [ -t 0 ]; then
  read -rp "proceed? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || die "aborted"
fi

mkdir -p "$(dirname "$DEST")"
mv "$SRC" "$DEST"
ok "moved → $DEST"

# Stow
"$DOTFILES/setup.sh" "$PKG"

# Verify symlink
if [ -L "$SRC" ]; then
  ok "symlink created: $SRC → $(readlink "$SRC")"
else
  die "stow did not create symlink at $SRC — investigate"
fi
