# ~/.zshrc

# ─── History ──────────────────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS       # replaces HISTCONTROL=ignoreboth
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
export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH:/usr/local/bin:/usr/local/go/bin"

# ─── Navigation ───────────────────────────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

alias cdobs='cd /mnt/c/Users/aeidl/git/personal/obsidian/My\ 2nd\ Brain/'
alias cdtmp='cd /mnt/c/Temp/'
alias cdodchg='cd /mnt/c/Users/aeidl/OneDrive\ -\ Emmi/Dokumente/98-CHG_Unterlagen/2026/'
alias cdh='cd /mnt/c/users/aeidl/'
alias cdgw='cd /mnt/c/users/aeidl/git/emmi/'
alias cdod='cd /mnt/c/Users/aeidl/OneDrive - Emmi/Dokumente/'

# ─── eza (ls replacement) ─────────────────────────────────────────────────────
alias l='eza -lah --icons'
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
alias gd='git diff'
alias gpl='git pull'
alias gdc='git diff --cached'
alias gl='git log --oneline --graph --decorate'
alias gb='git branch'
alias gr='git restore'

# ─── fzf ─────────────────────────────────────────────────────────

source /usr/share/doc/fzf/examples/key-bindings.zsh


export EDITOR=nvim
export VISUAL=nvim

# ===== Azure DevOps pipelines (CPI) =====
# Requires: az + azure-devops extension, defaults set via `az devops configure`

# --- generic ---
alias apl='az pipelines list -o table'
alias apx='az pipelines runs list --top 10 -o table'
alias apv='az pipelines variable-group list -o table'

aps() {
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    az pipelines show --id "$1" --query "{id:id,name:name,yaml:process.yamlFilename,queue:queue.name}" -o table
  else
    az pipelines show --name "$1" --query "{id:id,name:name,yaml:process.yamlFilename,queue:queue.name}" -o table
  fi
}

apr() {
  local name="$1"; shift
  az pipelines run --name "$name" ${@:+--parameters "$@"} -o table
}

aprl() { az pipelines runs list --pipeline-ids "$1" --top 10 -o table }

aprs() {
  az pipelines runs show --id "$1" \
    --query "{id:id,status:status,result:result,started:startTime,finished:finishTime,url:_links.web.href}" -o table
}

apro() {
  local org project url cfg=~/.azure/azuredevops/config
  org=$(awk -F' *= *' '/^organization/{print $2; exit}' "$cfg" 2>/dev/null)
  project=$(awk -F' *= *' '/^project/{print $2; exit}' "$cfg" 2>/dev/null)
  if [[ -z "$org" || -z "$project" ]]; then
    echo "set defaults: az devops configure --defaults organization=... project=..." >&2
    return 1
  fi
  project=${project// /%20}
  url="${org%/}/${project}/_build/results?buildid=$1"
  echo "$url"
  powershell.exe -NoProfile -Command "Start-Process '$url'" >/dev/null 2>&1
}

aprw() {
  while :; do
    local r=$(az pipelines runs show --id "$1" --query "{s:status,r:result}" -o tsv)
    echo "$(date +%H:%M:%S)  $r"
    [[ "$r" == *completed* ]] && break
    sleep 15
  done
}

# --- CPI-specific shortcuts ---
alias cpi-snap='apr "CPI - Snapshot (scheduled)"'
cpi-snap-dev() { apr "CPI - Snapshot (scheduled)" tenant=dev "$@" }
cpi-snap-prd() { apr "CPI - Snapshot (scheduled)" tenant=prd "$@" }
cpi-sync() {
  local t="$1" pkg="$2"; shift 2
  apr "CPI - Sync Package (manual)" tenant="$t" packageId="$pkg" "$@"
}

# CPI drift radar
alias cpi-drift='apr "CPI - Compare Tenants (manual)"'
# usage:
#   cpi-drift                                          # default: tenant/dev vs tenant/prd
#   cpi-drift branchA=tenant/dev branchB=main          # override
