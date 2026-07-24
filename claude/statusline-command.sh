#!/bin/bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")

# git segment: cyan dir, blue git:(branch), red ✗ if dirty
git_seg="\033[36m${dir}\033[0m"
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" describe --tags --exact-match 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if ! git -C "$cwd" -c core.useBuiltinFSMonitor=false diff-index --quiet HEAD -- 2>/dev/null || [ -n "$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null)" ]; then
        git_seg="${git_seg} \033[1;34mgit:(${branch})\033[0m \033[1;31m✗\033[0m"
    else
        git_seg="${git_seg} \033[1;34mgit:(${branch})\033[0m"
    fi
fi

# model + context% + cost in one jq pass; context% falls back to manual calc
read -r model ctx cost < <(echo "$input" | jq -r '
    (.model.display_name // "?") as $m
    | (.context_window.used_percentage
       // (if (.context_window.context_window_size // 0) > 0
           then ((.context_window.current_usage.input_tokens // 0)
               + (.context_window.current_usage.cache_creation_input_tokens // 0)
               + (.context_window.current_usage.cache_read_input_tokens // 0))
               / .context_window.context_window_size * 100
           else null end)) as $c
    | (.cost.total_cost_usd // 0) as $u
    | "\($m) \(if $c == null then "-" else (($c | floor | tostring) + "%") end) \($u | . * 100 | round / 100)"')

# yellow context% once past 80, else dim
ctx_col="\033[2m"
[ "${ctx%\%}" != "-" ] && [ "${ctx%\%}" -ge 80 ] 2>/dev/null && ctx_col="\033[1;33m"

printf "${git_seg}  \033[2m%s\033[0m ${ctx_col}%s\033[0m \033[2m\$%s\033[0m " "$model" "$ctx" "$cost"
