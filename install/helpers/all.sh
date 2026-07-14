#!/usr/bin/env bash
# install/helpers/all.sh - shared functions sourced by all install scripts

# --- logging ---
_c_reset=$'\e[0m'; _c_bold=$'\e[1m'
_c_blue=$'\e[34m'; _c_green=$'\e[32m'; _c_yellow=$'\e[33m'; _c_red=$'\e[31m'

log()  { printf '%s==>%s %s\n'  "$_c_blue"   "$_c_reset" "$*"; }
ok()   { printf '%s ✓ %s%s\n'   "$_c_green"  "$*" "$_c_reset"; }
warn() { printf '%s ! %s%s\n'   "$_c_yellow" "$*" "$_c_reset" >&2; }
err()  { printf '%s ✗ %s%s\n'   "$_c_red"    "$*" "$_c_reset" >&2; }
die()  { err "$*"; exit 1; }

run_logged() {
    local script=$1
    log "run: $(basename "$script")"
    # shellcheck disable=SC1090
    source "$script"
}

# --- package installation ---
# read_pkglist <name>  -> echoes packages (strips comments + blanks)
read_pkglist() {
    local file="$DOTFILES/install/$1.packages"
    [ -f "$file" ] || die "package list not found: $file"
    sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$file"
}

pac_install() {
    local list=$1
    local pkgs
    mapfile -t pkgs < <(read_pkglist "$list")
    [ ${#pkgs[@]} -gt 0 ] || { warn "no packages in $list"; return 0; }
    log "pacman -S --needed (${#pkgs[@]} pkgs from $list.packages)"
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
    ok "$list installed"
}

aur_install() {
    local list=$1
    command -v yay >/dev/null || die "yay missing. Run preflight first."
    local pkgs
    mapfile -t pkgs < <(read_pkglist "$list")
    [ ${#pkgs[@]} -gt 0 ] || { warn "no packages in $list"; return 0; }
    log "yay -S --needed (${#pkgs[@]} pkgs from $list.packages)"
    yay -S --needed --noconfirm "${pkgs[@]}"
    ok "$list (AUR) installed"
}
