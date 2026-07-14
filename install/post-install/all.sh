#!/usr/bin/env bash
# install/post-install/all.sh - enable services, print summary

post_enable_services() {
    log "enable system services"
    sudo systemctl enable sddm.service                 || true
    sudo systemctl enable --now ufw.service            || true
    sudo systemctl enable --now docker.service         || true
    sudo systemctl enable --now cups.service           || true
    sudo systemctl enable --now power-profiles-daemon  || true
    # iwd only if you picked it over NetworkManager
    # sudo systemctl enable --now iwd.service
}

post_ufw_defaults() {
    if command -v ufw >/dev/null; then
        log "configure ufw defaults"
        sudo ufw default deny incoming  || true
        sudo ufw default allow outgoing || true
        sudo ufw --force enable         || true
    fi
}

post_summary() {
    cat <<EOF

$(printf '\e[1;32m==> setup complete\e[0m')

Next steps:
  - reboot to graphical login (sddm)
  - re-login for docker group membership
  - review docs/ARCHPACKAGES.md for optional extras

EOF
}

post_enable_services
post_ufw_defaults
post_summary
