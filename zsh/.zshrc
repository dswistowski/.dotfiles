# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

plugins=(
  dotenv
  git
)

# Completion paths before Oh My Zsh loads completions
fpath=(
  "$HOME/.zfunc"
  "$HOME/.docker/completions"
  "$HOME/.local/share/zsh/site-functions"
  "$HOME/.zfunc"
  $fpath
)

source "$ZSH/oh-my-zsh.sh"

# Prompt: Pure
fpath+=("$HOME/.zsh/pure")
autoload -Uz promptinit
promptinit
prompt pure

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/Library/Android/sdk/platform-tools:$PATH"
export PATH="$HOME/google-cloud-sdk/bin:$PATH"
export PATH="$PATH:./node_modules/.bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/Users/damian/bin:/opt/homebrew/bin:$PATH"

# Python / pyenv
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Cargo
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Better autocomplete behavior
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Bash-style completions
autoload -Uz bashcompinit
bashcompinit

# Google Cloud SDK
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && source "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && source "$HOME/google-cloud-sdk/completion.zsh.inc"

# Vault completion
[ -x /opt/homebrew/bin/vault ] && complete -o nospace -C /opt/homebrew/bin/vault vault

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Tabtab completions
[ -f "$HOME/.config/tabtab/zsh/__tabtab.zsh" ] && source "$HOME/.config/tabtab/zsh/__tabtab.zsh"


# Aliases
alias ls='ls --color=auto'
alias vi=nvim
alias vim=nvim

# TTY sends different key codes. Translate them to regular.
bindkey -s '^[[1~' '^[[H'
bindkey -s '^[[4~' '^[[F'

# History search
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Key bindings
bindkey '^?'      backward-delete-char
bindkey '^[[3~'   delete-char
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^H'      backward-kill-word
bindkey '^[[3;5~' kill-word
bindkey '^J'      backward-kill-line
bindkey '^[[D'    backward-char
bindkey '^[[C'    forward-char
bindkey '^[[A'    up-line-or-beginning-search
bindkey '^[[B'    down-line-or-beginning-search

# FZF
export FZF_DEFAULT_COMMAND='ag -g ""'
bindkey -s '^o' 'nvim $(fzf)^M'
bindkey -s '^e' 'open-editor $(pwd)^M'

# Hooks
autoload -Uz add-zsh-hook

_local_rc_after_cd() {
  if [ -f .localrc ]; then
    source .localrc
  fi
}

load_dotenv() {
  if [ -f .env ]; then
    set -a
    source .env
    set +a
    echo "ℹ️ .env loaded"
  fi
}

add-zsh-hook chpwd _local_rc_after_cd
add-zsh-hook chpwd load_dotenv

# Helper
load-env() {
  if [ -f "$1" ]; then
    set -o allexport
    source "$1"
    set +o allexport
  else
    echo "load-env: file '$1' not found"
    return 1
  fi
}

# Editor
export GIT_EDITOR=nvim
export AWS_PROFILE=Developer-310188666820
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
eval "$(fnm env --use-on-cd --shell zsh)"

#
unalias gb 2>/dev/null
source ~/.dotfiles/tools/gb-cli/completions/gb.zsh
#compdef gt
###-begin-gt-completions-###
#
# yargs command completion script
#
# Installation: gt completion >> ~/.zshrc
#    or gt completion >> ~/.zprofile on OSX.
#
_gt_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gt_yargs_completions gt
###-end-gt-completions-###

export VOLTA_FEATURE_PNPM=1

eval "$(direnv hook zsh)"

export PNPM_HOME="/Users/dswistowski/Library/pnpm"

export PATH="$PNPM_HOME/bin:$PATH"
