#!/usr/bin/env bash
# install/packaging/all.sh - install every package group

for phase in base fonts terminal screenshot tui editors files browsers audio printing dev system util; do
    pac_install "$phase"
done

aur_install aur

log "refresh font cache"
fc-cache -f >/dev/null 2>&1 || true
ok "packaging complete"
