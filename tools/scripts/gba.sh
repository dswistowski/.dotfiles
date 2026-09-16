#!/bin/bash
#
# Show local git branches alongside their GitHub PR status and title.
# Run from inside a GitHub repo where local branch names map to PR heads.
# Requires: git, gh, jq
#
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[1;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'
current=$(git branch --show-current)
git branch --format='%(refname:short)' | while read -r branch; do
  if [ "$branch" = "$current" ]; then
    display_branch="* $branch"
  else
    display_branch="  $branch"
  fi
  pr_json=$(gh pr view "$branch" --json number,title,state,isDraft,url 2>/dev/null)
  if [ $? -eq 0 ]; then
    number=$(echo "$pr_json" | jq -r '.number')
    title=$(echo "$pr_json" | jq -r '.title')
    state=$(echo "$pr_json" | jq -r '.state')
    isDraft=$(echo "$pr_json" | jq -r '.isDraft')
    url=$(echo "$pr_json" | jq -r '.url')
    case "$state" in
      OPEN)
        if [ "$isDraft" = "true" ]; then
          state_label="${DIM}${YELLOW}DRAFT${NC}"
        else
          state_label="${GREEN}OPEN${NC}"
        fi ;;
      MERGED) state_label="${CYAN}MERGED${NC}" ;;
      CLOSED) state_label="${RED}CLOSED${NC}" ;;
    esac
    pr_link="\e]8;;${url}\e\\#${number}\e]8;;\e\\"
    printf "${BOLD}${BLUE}%-30s${NC} %b [%b] %s\n" \
      "$display_branch" "$pr_link" "$state_label" "$title"
  else
    printf "${DIM}%-30s  (no PR)${NC}\n" "$display_branch"
  fi
done
