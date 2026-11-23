#!/bin/bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

if [[ $(uname -s) != Darwin || $(uname -m) != arm64 ]]; then
    printf '%s\n' 'Run this from a native Apple Silicon macOS terminal.' >&2
    exit 1
fi

brew=/opt/homebrew/bin/brew
if [[ ! -x "$brew" ]]; then
    brew_installer=$(/usr/bin/curl --fail --silent --show-error --location \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
    /bin/bash -c "$brew_installer"
fi

brew_env=$("$brew" shellenv bash)
eval "$brew_env"
"$brew" bundle install --file="$repo_dir/Brewfile" --no-upgrade

# Detect conflicting files before linking anything or installing shell extensions.
"$repo_dir/install.sh" --dry-run

ensure_shell_checkout() {
    local url=$1 destination=$2 entry_file=$3
    if [[ ! -e "$destination" && ! -L "$destination" ]]; then
        mkdir -p -- "$(dirname -- "$destination")"
        git clone --depth 1 "$url" "$destination"
    fi

    if [[ ! -r "$destination/$entry_file" ]]; then
        printf 'Expected %s in %s. Fix or move that directory and rerun.\n' \
            "$entry_file" "$destination" >&2
        return 1
    fi
}

ensure_shell_checkout https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" oh-my-zsh.sh
ensure_shell_checkout https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure" prompt_pure_setup

"$repo_dir/install.sh"
printf '\n%s\n' 'Setup complete. Open a new terminal to load the dotfiles.'
