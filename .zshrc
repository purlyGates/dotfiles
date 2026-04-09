# ~/.zshrc

# ─── History ──────────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_BOTH       # replaces HISTCONTROL=ignoreboth
setopt HIST_APPEND            # replaces shopt -s histappend
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# ─── Vi mode ──────────────────────────────────────────────────────────────────
bindkey -v  # enable vi mode (skip if already set elsewhere)

# Change cursor shape per mode
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[1 q'  # block cursor  = NORMAL mode
  else
    echo -ne '\e[5 q'  # beam cursor   = INSERT mode
  fi
}
zle -N zle-keymap-select

# Beam cursor on startup and after each command
function zle-line-init {
  echo -ne '\e[5 q'
}
zle -N zle-line-init

preexec() { echo -ne '\e[5 q'; }

# ─── Path ─────────────────────────────────────────────────────────────────────
export GOPATH=$HOME/go
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"

# ─── Navigation ───────────────────────────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

alias cdobswork='cd /mnt/c/Users/aeidl/OneDrive\ -\ Emmi/Apps/Obsidian/Work/'
alias cdobs='cd /mnt/c/Users/aeidl/Proton\ Drive/aris.lanz/My\ files/Obsidian/My\ 2nd\ Brain/'
alias cdtmp='cd /mnt/c/Temp/'
alias cdodchg='cd /mnt/c/Users/aeidl/OneDrive\ -\ Emmi/Dokumente/98-CHG_Unterlagen/2026/'
alias cdbrunodis='cd /mnt/c/Users/aeidl/OneDrive\ -\ Emmi/Apps/Bruno'

# ─── Eza (ls replacement) ─────────────────────────────────────────────────────
alias l='eza -lah --icons --git'
alias lt='eza --tree --level=2 --long --icons --git'
alias ltree='eza --tree --level=2 --icons --git'

# ─── Editor ───────────────────────────────────────────────────────────────────
alias v='nvim'

# ─── Clipboard ────────────────────────────────────────────────────────────────
alias pbcopy='xsel --input --clipboard'
alias pbpaste='xsel --output --clipboard'

# ─── Grep colors ──────────────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ─── bat ──────────────────────────────────────────────────────────────────────
alias cat='batcat'

# ─── Fabric ───────────────────────────────────────────────────────────────────
if [ -d "$HOME/.config/fabric/patterns" ]; then
  for pattern_file in "$HOME/.config/fabric/patterns/"*; do
    pattern_name=$(basename "$pattern_file")
    alias "$pattern_name"="fabric --pattern $pattern_name"  # no eval needed in zsh
  done
fi

yt() {
  if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
    echo "Usage: yt [-t | --timestamps] youtube-link"
    return 1
  fi
  local transcript_flag="--transcript"
  if [ "$1" = "-t" ] || [ "$1" = "--timestamps" ]; then
    transcript_flag="--transcript-with-timestamps"
    shift
  fi
  fabric -y "$1" $transcript_flag
}

[ -f "$HOME/.config/fabric/completions/fabric.bash" ] &&
  source "$HOME/.config/fabric/completions/fabric.bash"

# ─── PDF → Cornell Notes ──────────────────────────────────────────────────────
pdf2cornell() {
  if [ -z "$1" ]; then
    echo "Usage: pdf2cornell <file.pdf>"
    return 1
  fi
  pdftotext -layout "$1" - | extract_wisdom | fabric -scp cornell_note
}

# ─── Scripts ──────────────────────────────────────────────────────────────────
alias print_iflow='python3 ~/scripts/python/print_iflow_markdown.py'

# ─── Zsh completion ───────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

# ─── NVM ──────────────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # still works in zsh

# ─── Starship prompt ──────────────────────────────────────────────────────────
eval "$(starship init zsh)"  # changed: bash → zsh

source ~/.secrets

# ─── Git ─────────────────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log --oneline --graph --decorate'
alias gb='git branch'

