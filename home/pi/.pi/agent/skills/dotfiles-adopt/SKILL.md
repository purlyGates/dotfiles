---
name: dotfiles-adopt
description: "Adopt a config file or directory from the user's home into their GNU stow-managed dotfiles repo (~/dotfiles) and create the symlink back. Use when the user wants to move an existing config (e.g. ~/.config/nvim, ~/.zshrc, ~/.gitconfig) into version control and symlink it via stow. Handles both XDG configs (~/.config/*) and home-rooted dotfiles (~/.foo). Assumes split-package layout - ~/dotfiles/config/ (target ~/.config) and ~/dotfiles/home/ (target ~), with ~/dotfiles/setup.sh as stow wrapper."
---

# dotfiles-adopt

Adopts an existing config into `~/dotfiles`, then stows it so a symlink replaces the original path.

## Assumed repo layout

```
~/dotfiles/
├── setup.sh              # ./setup.sh <pkg> runs stow with correct target
├── config/               # .stowrc: --target=~/.config
│   └── <pkg>/...
└── home/                 # .stowrc: --target=~
    └── <pkg>/...
```

## Usage

```bash
./adopt.sh <path> [package_name]
```

- `<path>`: existing file/dir under `$HOME` (must not already be a symlink).
- `[package_name]`: optional. Inferred if omitted:
  - `~/.config/nvim`         → package `nvim`
  - `~/.config/starship.toml`→ package `starship` (extension stripped)
  - `~/.zshrc`               → package `zsh` (leading dot + trailing `rc` stripped)
  - `~/.gitconfig`           → package `git`

## Behavior

1. Determines whether path lives under `~/.config` (→ `config/` root) or directly under `~` (→ `home/` root).
2. Infers package name unless given.
3. Prints plan, asks for confirmation (TTY only).
4. `mv` original into `~/dotfiles/<root>/<pkg>/<relative-path>` (mirrors stow-target layout).
5. Runs `~/dotfiles/setup.sh <pkg>` to create the symlink.
6. Verifies symlink at original path.

## Examples

```bash
./adopt.sh ~/.config/nvim
./adopt.sh ~/.config/starship.toml
./adopt.sh ~/.zshrc                    # → package "zsh"
./adopt.sh ~/.zshrc myshell            # override package name
./adopt.sh ~/.gitconfig git
```

## Environment

- `DOTFILES` env var overrides repo path (default `~/dotfiles`).

## Safety notes

- Refuses if source is already a symlink.
- Refuses if destination in repo already exists (no clobber).
- Uses `mv` (not `cp`) so there is a brief window where the file lives only in the repo before stow runs. If stow fails, file is at `$DOTFILES/<root>/<pkg>/...` — restore manually.

## When invoked by the agent

If the user asks to "adopt", "move to dotfiles", "add to stow", "put in dotfiles repo", or similar for a specific path:

1. Read this SKILL.md.
2. Ensure the script is executable: `chmod +x ~/.pi/agent/skills/dotfiles-adopt/adopt.sh`.
3. Run it with the target path. Suggest an explicit package name if inference looks wrong.
4. Report the final symlink and repo path.
