#!/bin/bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
stow_args=(--dir="$repo_dir" --target="$HOME" --no-folding)

case "${1-}" in
    "") ;;
    --dry-run) stow_args+=(--simulate --verbose) ;;
    *)
        printf 'Usage: %s [--dry-run]\n' "$0" >&2
        exit 2
        ;;
esac

stow "${stow_args[@]}" nvim tmux zsh tools git skhd alacritty codex
