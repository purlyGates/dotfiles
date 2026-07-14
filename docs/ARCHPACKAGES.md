## Phase 1. Bootstrap yay (AUR helper)

Several later packages live only in AUR. `yay` itself is AUR: build from source once.

```bash
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

Verify: `yay --version`.

## Phase 2. Core desktop (Hyprland stack)

Wayland compositor + shell. Everything needed to boot into a working graphical session.

### Packages (official repo)

- **`hyprland`**: tiling Wayland compositor
- **`hypridle`**: idle daemon (lock / sleep on inactivity)
- **`hyprlock`**: screen locker
- **`hyprpicker`**: color picker
- **`hyprsunset`**: blue-light filter
- **`uwsm`**: universal Wayland session manager, launches Hyprland cleanly
- **`waybar`**: status bar
- **`mako`**: notification daemon
- **`swaybg`**: wallpaper setter
- **`swayosd`**: on-screen volume / brightness popup
- **`fuzzel`**: application launcher (Wayland-native, lightweight)
- **`xdg-desktop-portal-hyprland`**: portal for screen share, file pickers (Hyprland)
- **`xdg-desktop-portal-gtk`**: portal (GTK backend)
- **`xdg-terminal-exec`**: opens terminal from `.desktop` files
- **`xdg-user-dirs`**: creates `~/Documents`, `~/Downloads`, `~/Pictures`, ...
- **`polkit-gnome`**: GUI auth prompts for privileged actions
- **`sddm`**: login manager (display manager)
- **`plymouth`**: boot splash
- **`qt5-wayland`**: Qt5 Wayland support
- **`qt6-wayland`**: Qt6 Wayland support
- **`kvantum-qt5`**: Qt theming engine
- **`gnome-themes-extra`**: GTK themes
- **`yaru-icon-theme`**: icon theme

### Packages (AUR, via yay)

- **`hyprland-guiutils`**: GUI helpers for Hyprland
- **`hyprland-preview-share-picker`**: screen-share picker window

### Install

```bash
pacman -S hyprland hypridle hyprlock hyprpicker hyprsunset uwsm \
    waybar mako swaybg swayosd fuzzel \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    xdg-terminal-exec xdg-user-dirs polkit-gnome \
    sddm plymouth \
    qt5-wayland qt6-wayland kvantum-qt5 \
    gnome-themes-extra yaru-icon-theme

yay -S hyprland-guiutils hyprland-preview-share-picker

systemctl enable sddm
xdg-user-dirs-update
```

## Phase 3. Fonts

Includes bar icons, emoji, CJK coverage.

- **`ttf-jetbrains-mono-nerd`**: main mono font with Nerd Font icons (used by Waybar, terminal)
- **`ttf-font-awesome`**: Font Awesome icons in TTF (Waybar renders these)
- **`ttf-ia-writer`**: writing / prose font
- **`noto-fonts`**: broad Unicode Latin / other scripts
- **`noto-fonts-cjk`**: Chinese / Japanese / Korean glyphs
- **`noto-fonts-emoji`**: color emoji
- **`fontconfig`**: font system

```bash
pacman -S ttf-jetbrains-mono-nerd ttf-font-awesome ttf-ia-writer \
    noto-fonts noto-fonts-cjk noto-fonts-emoji fontconfig
fc-cache
```

## Phase 4. Terminal + shell + CLI utils

Quality-of-life shell environment.

- **`alacritty`**: GPU-accelerated terminal (Omarchy default)
- **`starship`**: shell prompt
- **`tmux`**: terminal multiplexer
- **`bash-completion`**: tab-completion for bash
- **`fastfetch`**: system info banner
- **`bat`**: better `cat` with syntax highlighting
- **`eza`**: better `ls`
- **`fd`**: better `find`
- **`ripgrep`**: better `grep`
- **`fzf`**: fuzzy finder
- **`zoxide`**: smart `cd` (learns your habits)
- **`dust`**: better `du`, tree with size bars
- **`btop`**: process / resource monitor
- **`jq`**: JSON CLI
- **`xmlstarlet`**: XML CLI
- **`plocate`**: fast file locate
- **`tldr`**: short community man pages
- **`man-db`**: man page system
- **`less`**: pager
- **`gum`**: pretty shell prompts / dialogs
- **`expac`**: pacman database query
- **`whois`**: WHOIS lookup client
- **`inetutils`**: `ping`, `hostname`, `telnet`, ...
- **`inxi`**: hardware / system info
- **`unzip`**: extract zip archives
- **`socat`**: bidirectional socket relay (Hyprland IPC scripts use it)

```bash
pacman -S alacritty starship tmux bash-completion fastfetch \
    bat eza fd ripgrep fzf zoxide dust btop \
    jq xmlstarlet plocate tldr man-db less \
    gum expac whois inetutils inxi unzip socat
```

## Phase 5. Screenshots / recording / clipboard

- **`grim`**: Wayland screenshot tool
- **`slurp`**: region selector (pipes into grim)
- **`satty`**: annotate screenshots
- **`wl-clipboard`**: clipboard CLI (`wl-copy` / `wl-paste`)
- **`gpu-screen-recorder`**: hardware-accelerated screen recorder
- **`obs-studio`**: streaming / advanced recording
- **`tesseract`**: OCR engine
- **`tesseract-data-eng`**: English OCR training data
- **`imagemagick`**: image CLI (`convert`, `mogrify`)
- **`ffmpegthumbnailer`**: video thumbnails in file manager

```bash
pacman -S grim slurp satty wl-clipboard \
    gpu-screen-recorder obs-studio \
    tesseract tesseract-data-eng imagemagick ffmpegthumbnailer
```

## Phase 6. TUI tools

- **`impala`**: Wi-Fi TUI (uses `iwd`)
- **`bluetui`**: Bluetooth TUI
- **`wiremix`**: PipeWire mixer TUI (per-app volume, sink switching)
- **`lazygit`**: git TUI
- **`lazydocker`**: docker TUI

### AUR

- **`cliamp`**: music player TUI (Omarchy custom)

```bash
pacman -S impala bluetui wiremix lazygit lazydocker
yay -S cliamp
```

## Phase 7. Editors

- **`neovim`**: Neovim (note: package is `neovim`, not `nvim`)
- **`tree-sitter-cli`**: parsers for syntax-aware plugins
- **`luarocks`**: Lua package manager (plugin dependencies)

```bash
pacman -S neovim tree-sitter-cli luarocks
```

## Phase 8. File manager / viewers / creative

- **`nautilus`**: GNOME file manager
- **`nautilus-python`**: Python extensions for Nautilus
- **`sushi`**: quick-preview extension (spacebar preview)
- **`gnome-disk-utility`**: partition / disk GUI
- **`gvfs-nfs`**: mount NFS shares in Nautilus
- **`gvfs-smb`**: mount SMB / Windows shares in Nautilus
- **`imv`**: fast image viewer
- **`mpv`**: video player
- **`evince`**: PDF viewer
- **`pinta`**: simple raster paint (Paint.NET clone)
- **`kdenlive`**: non-linear video editor
- **`libreoffice-fresh`**: office suite

### AUR

- **`obsidian`**: notes app (also available in `extra` repo, check `pacman -Si obsidian` first)

```bash
pacman -S nautilus nautilus-python sushi gnome-disk-utility \
    gvfs-nfs gvfs-smb \
    imv mpv evince pinta kdenlive libreoffice-fresh

# if obsidian in extra:
pacman -S obsidian
# else:
yay -S obsidian
```

## Phase 9. Browsers / comms

- **`chromium`**: browser (also runs PWAs / web apps)
- **`localsend`**: cross-device file share (AirDrop-like)

### AUR

- **`spotify`**: music (closed source). Alternative: `spotify-launcher` from `extra` (downloads official binary on first run, no AUR).

```bash
pacman -S chromium localsend
# pick one:
pacman -S spotify-launcher   # simpler
# yay -S spotify              # or full AUR build
```

## Phase 10. Audio / media stack

`pipewire` + `wireplumber` are installed by `archinstall` audio profile. Add compatibility layers + tools.

- **`wireplumber`**: PipeWire session manager
- **`pipewire-alsa`**: ALSA -> PipeWire compat
- **`pipewire-jack`**: JACK -> PipeWire compat
- **`pipewire-pulse`**: PulseAudio -> PipeWire compat
- **`gst-plugin-pipewire`**: GStreamer plugin for PipeWire
- **`libpulse`**: PulseAudio client library (many apps link against this)
- **`pamixer`**: PulseAudio-compatible CLI mixer (used in Waybar / keybinds)
- **`playerctl`**: MPRIS media key control
- **`alsa-utils`**: low-level ALSA CLI (`alsamixer`)

```bash
pacman -S wireplumber pipewire-alsa pipewire-jack pipewire-pulse \
    gst-plugin-pipewire libpulse \
    pamixer playerctl alsa-utils
```

## Phase 11. Printing (home use, bare minimum)

- **`cups`**: print server
- **`cups-filters`**: filters to convert print jobs into printer language
- **`system-config-printer`**: printer configuration GUI

For network printers add `avahi` + `nss-mdns` (mDNS discovery). Add printer driver package on demand: `gutenprint` (many), `hplip` (HP), or brother packages from AUR.

```bash
pacman -S cups cups-filters system-config-printer
systemctl enable --now cups
```

## Phase 12. Dev toolchain

Kept minimal. Add language runtimes on demand.

- **`git`**: version control
- **`docker`**: containers
- **`docker-buildx`**: extended build features
- **`docker-compose`**: multi-container orchestration

```bash
pacman -S git docker docker-buildx docker-compose
systemctl enable --now docker
usermod -aG docker "$USER"   # log out / in for group to apply
```

## Phase 14. System, power, network, security

- **`iwd`**: Wi-Fi daemon (pairs with `impala` TUI)
- **`wireless-regdb`**: Wi-Fi regulatory database
- **`ufw`**: firewall frontend
- **`power-profiles-daemon`**: laptop perf / balanced / powersave
- **`brightnessctl`**: backlight control
- **`kernel-modules-hook`**: keeps old kernel modules loaded after upgrade (prevents USB / module breakage before reboot)
- **`dosfstools`**: FAT filesystem tools (USB sticks)
- **`exfatprogs`**: exFAT filesystem tools
- **`gnome-keyring`**: secrets storage daemon (Chromium, git credentials, Signal, ... expect it)
- **`libsecret`**: Secret Service API library
- **`openssh`**: SSH client + optional server

### AUR

- **`tzupdate`**: auto timezone based on IP. Optional; `timedatectl set-timezone Europe/Berlin` works fine as one-off.

```bash
pacman -S iwd wireless-regdb ufw power-profiles-daemon brightnessctl \
    kernel-modules-hook dosfstools exfatprogs \
    gnome-keyring libsecret openssh

systemctl enable --now ufw
systemctl enable --now power-profiles-daemon
ufw default deny incoming
ufw default allow outgoing
ufw enable

# yay -S tzupdate   # optional
```

## Phase 15. Utility

- **`gnome-calculator`**: calculator GUI
- **`libqalculate`**: calculator engine + `qalc` CLI

```bash
pacman -S gnome-calculator libqalculate
```

## Phase 16. Post-install

```bash
# generate XDG user dirs
xdg-user-dirs-update

# enable services
systemctl enable sddm
systemctl enable --now iwd            # if picked over NetworkManager
systemctl enable --now cups           # if printing
systemctl enable --now docker
systemctl enable --now ufw

# reboot into graphical session
reboot
```

## Package arrays (for automation scripts)

Copy-paste blocks for a bash installer script.

```bash
PACMAN_PKGS=(
    # Hyprland stack
    hyprland hypridle hyprlock hyprpicker hyprsunset uwsm
    waybar mako swaybg swayosd fuzzel
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    xdg-terminal-exec xdg-user-dirs polkit-gnome
    sddm plymouth
    qt5-wayland qt6-wayland kvantum-qt5
    gnome-themes-extra yaru-icon-theme

    # Fonts
    ttf-jetbrains-mono-nerd ttf-font-awesome ttf-ia-writer
    noto-fonts noto-fonts-cjk noto-fonts-emoji fontconfig

    # Shell / CLI
    alacritty starship tmux bash-completion fastfetch
    bat eza fd ripgrep fzf zoxide dust btop
    jq xmlstarlet plocate tldr man-db less
    gum expac whois inetutils inxi unzip socat

    # Screenshots / media capture
    grim slurp satty wl-clipboard
    gpu-screen-recorder obs-studio
    tesseract tesseract-data-eng imagemagick ffmpegthumbnailer

    # TUIs
    impala bluetui wiremix lazygit lazydocker

    # Editors
    neovim tree-sitter-cli luarocks

    # File manager / viewers / creative
    nautilus nautilus-python sushi gnome-disk-utility
    gvfs-nfs gvfs-smb
    imv mpv evince pinta kdenlive libreoffice-fresh

    # Browser / comms
    chromium localsend spotify-launcher

    # Audio
    wireplumber pipewire-alsa pipewire-jack pipewire-pulse
    gst-plugin-pipewire libpulse
    pamixer playerctl alsa-utils

    # Printing
    cups cups-filters system-config-printer

    # Dev
    git docker docker-buildx docker-compose

    # System / power / net / sec
    iwd wireless-regdb ufw power-profiles-daemon brightnessctl
    kernel-modules-hook dosfstools exfatprogs
    gnome-keyring libsecret openssh

    # Utility
    gnome-calculator libqalculate
)

AUR_PKGS=(
    hyprland-guiutils
    hyprland-preview-share-picker
    cliamp
    # obsidian     # only if not in extra
    # tzupdate     # optional
)

sudo pacman -S --needed "${PACMAN_PKGS[@]}"
yay -S --needed "${AUR_PKGS[@]}"
```
