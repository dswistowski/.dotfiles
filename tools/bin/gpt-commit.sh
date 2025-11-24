#!/usr/bin/env bash
set -euo pipefail

export OPENAI_API_KEY=$(pass personl/OPENAI_API_KEY)

AMEND=0
MODEL="${OPENAI_MODEL:-gpt-4.1-mini}"

if [[ "${1:-}" == "--amend" ]]; then
  AMEND=1
fi

# Use staged diff, or diff to HEAD when amending
if [[ $AMEND -eq 1 ]]; then
  DIFF=$(git diff HEAD || true)
else
  if git diff --cached --quiet; then
    echo "No staged changes found."
    exit 1
  fi
  DIFF=$(git diff --cached || true)
fi

if [[ -z "$DIFF" ]]; then
  echo "No diff to summarize."
  exit 1
fi

# Extract DI ticket from branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" =~ (DI-[0-9]+) ]]; then
  TICKET="[${BASH_REMATCH[1]}]"
else
  TICKET=""
fi

##########################################
# AUTO GITMOJI
##########################################
pick_gitmoji() {
  local d="$1"
  if echo "$d" | grep -qiE "FIXME|TODO|bug|fix|error"; then echo ":bug:"; return; fi
  if echo "$d" | grep -qiE "test|spec|assert"; then echo ":white_check_mark:"; return; fi
  if echo "$d" | grep -qiE "README|docs|documentation|\\.md"; then echo ":memo:"; return; fi
  if echo "$d" | grep -qiE "refactor|cleanup|rename"; then echo ":recycle:"; return; fi
  if echo "$d" | grep -qiE "package.json|go.mod|Cargo.toml|requirements.txt|yarn.lock"; then echo ":arrow_up:"; return; fi
  if echo "$d" | grep -qiE "config|\\.env|\\.ya?ml|\\.toml"; then echo ":wrench:"; return; fi
  if echo "$d" | grep -qiE "remove|delete|deprecated"; then echo ":fire:"; return; fi
  if echo "$d" | grep -qiE "security|auth|permission"; then echo ":lock:"; return; fi
  if echo "$d" | grep -qiE "ui|css|html|frontend"; then echo ":lipstick:"; return; fi
  echo ":sparkles:"
}

GITMOJI=$(pick_gitmoji "$DIFF")

##########################################
# OPENAI CALL (correct syntax)
##########################################
generate_ai_msg() {
  local d="$1"

  uv tool run openai api chat.completions.create \
    --model "$MODEL" \
    --message system "Write a short, clear git commit message in imperative mood. No emojis. No ticket IDs." \
    --message user "Summarize this diff into a git commit message:\n\n$d"
}

AI_MSG=$(generate_ai_msg "$DIFF")

FINAL_MSG="$GITMOJI $TICKET $AI_MSG"

echo "------ Generated Commit Message ------"
echo "$FINAL_MSG"
echo "-------------------------------------"

read -rp "Use this commit message? (y/n) " CONFIRM

if [[ "$CONFIRM" == "y" ]]; then
  if [[ $AMEND -eq 1 ]]; then
    git commit --amend -m "$FINAL_MSG"
  else
    git commit -m "$FINAL_MSG"
  fi
else
  echo "Aborted."
fi

