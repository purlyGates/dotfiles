# dotfiles

Personal Arch Linux setup: package lists, install scripts, and dotfiles managed with GNU stow.

## Layout

```
dotfiles/
├── install.sh              # remote bootstrap (curl | bash entry point)
├── boot.sh                 # local orchestrator, runs install phases
├── setup.sh                # thin wrapper around stow (dotfile symlinks)
├── bin/                    # user scripts added to PATH
├── config/                 # stow packages → ~/.config
├── home/                   # stow packages → ~
├── install/
│   ├── helpers/all.sh      # logging, pac_install, aur_install
│   ├── preflight/all.sh    # base-devel, yay, stow bootstrap
│   ├── packaging/
│   │   └── all.sh          # installs every *.packages list
│   ├── config/all.sh       # stow, XDG dirs, docker group, ...
│   ├── post-install/all.sh # enable services, ufw, summary
│   └── *.packages          # flat pkg lists (pacman + AUR)
└── docs/
    └── ARCHPACKAGES.md     # narrative reference
```

## Full system bootstrap

On a fresh Arch install (after `archinstall`, logged in as user with sudo):

```bash
bash <(curl -sL https://raw.githubusercontent.com/aeidl/dotfiles/main/install.sh)
```

Or if repo already cloned:

```bash
cd ~/dotfiles
./boot.sh
```

Individual phase:

```bash
./boot.sh packaging       # only packages
./boot.sh config          # only stow + user config
```

## Dotfiles only

For a machine where system is already set up:

```bash
./setup.sh all            # stow every package
./setup.sh nvim           # stow just one
```

## Package lists

Edit `install/*.packages`. One package per line, `#` comments allowed.
The narrative rationale for each phase lives in `docs/ARCHPACKAGES.md`.

To add a new group `foo`:

1. create `install/foo.packages`
2. append `foo` to the loop in `install/packaging/all.sh`
