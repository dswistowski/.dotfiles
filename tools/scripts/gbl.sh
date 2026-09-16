#!/bin/bash
#
# Show a `gba.sh` overview for each immediate child git repo.
# Run from a parent directory that contains multiple repos.
# Requires: git, gh, jq, and this directory's `gba.sh`.
#
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
allowed_dirs=("$HOME/ledgy")
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

current_dir=$(pwd -P)
allowed=false
for allowed_dir in "${allowed_dirs[@]}"; do
  if [ "$current_dir" = "$allowed_dir" ]; then
    allowed=true
    break
  fi
done

if [ "$allowed" != "true" ]; then
  printf "${DIM}gbl.sh may only be run from:${NC} %s\n" "${allowed_dirs[*]}"
  exit 1
fi

found_repo=false

for dir in */; do
  [ -d "$dir" ] || continue

  if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    continue
  fi

  repo_name=${dir%/}
  found_repo=true

  printf "${BOLD}${CYAN}%s${NC}\n" "$repo_name"
  (
    cd "$dir" || exit 1
    "$SCRIPT_DIR/gba.sh"
  )
  printf "\n"
done

if [ "$found_repo" = "false" ]; then
  printf "${DIM}No immediate child git repos found.${NC}\n"
fi
