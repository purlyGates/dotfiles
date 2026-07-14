#!/usr/bin/env bash
# install/config/all.sh - deploy dotfiles and system-level config tweaks

config_stow() {
    log "stow dotfile packages"
    "$DOTFILES/setup.sh" all
}

config_user_dirs() {
    log "generate XDG user dirs"
    xdg-user-dirs-update || true
}

config_docker_group() {
    if getent group docker >/dev/null && ! id -nG "$USER" | grep -qw docker; then
        log "add $USER to docker group (re-login required)"
        sudo usermod -aG docker "$USER"
    fi
}

config_stow
config_user_dirs
config_docker_group
ok "config complete"
