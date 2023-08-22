#!/usr/bin/env bash

languages=$(echo "python typescript javascript rust" | tr " " "\n")
core_utils=$(echo "git find xargs sed awk" | tr " " "\n") 

selected=$(echo -e "${languages}\n${core_utils}" | fzf)

read -p "?> " query

if echo "$languages" | grep -qs $selected
then
    curl -s cht.sh/${selected}/$(echo "$query" | tr " " "+") | less -R
else
    curl -s cht.sh/${selected}~$(echo "$query" | tr " " "+") | less -R
fi
