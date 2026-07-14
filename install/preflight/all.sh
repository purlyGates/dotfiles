#!/usr/bin/env bash
# install/preflight/all.sh - pre-checks + bootstrap yay

preflight_root_check() {
    [ "$EUID" -ne 0 ] || die "do not run as root; sudo is invoked per-step"
    sudo -v || die "sudo required"
}

preflight_arch_check() {
    [ -f /etc/arch-release ] || die "not an Arch system (/etc/arch-release missing)"
}

preflight_base_tools() {
    log "install base build tools (base-devel, git)"
    sudo pacman -S --needed --noconfirm base-devel git
}

preflight_bootstrap_yay() {
    if command -v yay >/dev/null; then
        ok "yay already present: $(yay --version | head -1)"
        return 0
    fi
    log "bootstrap yay from AUR"
    local tmp
    tmp=$(mktemp -d)
    git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
    ok "yay installed"
}

preflight_stow() {
    if ! command -v stow >/dev/null; then
        log "install GNU stow"
        sudo pacman -S --needed --noconfirm stow
    fi
}

preflight_root_check
preflight_arch_check
preflight_base_tools
preflight_bootstrap_yay
preflight_stow
