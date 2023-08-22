fpath+=($HOME/.zsh/pure)

autoload -U promptinit; promptinit
prompt pure


export NVM_AUTO_USE=true
source ~/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh


# TTY sends different key codes. Translate them to regular.
bindkey -s '^[[1~' '^[[H'  # home
bindkey -s '^[[4~' '^[[F'  # end

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^?'      backward-delete-char          # bs         delete one char backward
bindkey '^[[3~'   delete-char                   # delete     delete one char forward
bindkey '^[[H'    beginning-of-line             # home       go to the beginning of line
bindkey '^[[F'    end-of-line                   # end        go to the end of line
bindkey '^[[1;5C' forward-word                  # ctrl+right go forward one word
bindkey '^[[1;5D' backward-word                 # ctrl+left  go backward one word
bindkey '^H'      backward-kill-word            # ctrl+bs    delete previous word
bindkey '^[[3;5~' kill-word                     # ctrl+del   delete next word
bindkey '^J'      backward-kill-line            # ctrl+j     delete everything before cursor
bindkey '^[[D'    backward-char                 # left       move cursor one char backward
bindkey '^[[C'    forward-char                  # right      move cursor one char forward
bindkey '^[[A'    up-line-or-beginning-search   # up         prev command in history
bindkey '^[[B'    down-line-or-beginning-search # down       next command in history


export SHIPCAT_MANIFEST_DIR=/Users/damian.swistowski/babylon/manifests


alias ls='ls --color=auto'

export PATH="$HOME/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"

plugin=(
  pyenv
)

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/Library/Android/sdk/platform-tools:$PATH"

source "$HOME/.cargo/env"

fpath+=~/.zfunc
autoload -Uz compinit && compinit
export PATH="$PATH:./node_modules/.bin"

export FZF_DEFAULT_COMMAND='ag -g ""'

bindkey -s '^f' 'tmux-sessioniser^M'
bindkey -s '^o' 'nvim $(fzf)^M'
bindkey -s '^e' 'open-editor $(pwd)^M'

