#!/bin/bash
#
# Delete local branches whose GitHub PR is already merged or closed.
# Run from inside a GitHub repo after reviewing the branches to remove.
# Requires: git, gh, jq
# Safety: skips the current branch plus `main` and `master`.
#
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'
current=$(git branch --show-current)
git branch --format='%(refname:short)' | while read -r branch; do
  if [ "$branch" = "$current" ] || [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
    continue
  fi
  pr_json=$(gh pr view "$branch" --json number,state,title 2>/dev/null)
  if [ $? -ne 0 ]; then
    continue
  fi
  state=$(echo "$pr_json" | jq -r '.state')
  number=$(echo "$pr_json" | jq -r '.number')
  title=$(echo "$pr_json" | jq -r '.title')
  if [ "$state" = "MERGED" ] || [ "$state" = "CLOSED" ]; then
    printf "${DIM}Deleting${NC} ${BOLD}%s${NC} (#%s %b) %s\n" \
      "$branch" "$number" \
      "$([ "$state" = "MERGED" ] && echo "${CYAN}MERGED${NC}" || echo "${RED}CLOSED${NC}")" \
      "$title"
    git branch -D "$branch"
  fi
done
printf "\n${GREEN}Done.${NC}\n"
