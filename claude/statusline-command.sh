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

# magenta ‹worktree› when in one
wt=$(echo "$input" | jq -r '.worktree.name // empty')
[ -n "$wt" ] && git_seg="${git_seg} \033[35m‹${wt}›\033[0m"

# one jq pass, tab-separated: model, fast(⚡|-), effort(|-), ctx%, quota%(|-)
# ctx% falls back to a manual token calc when used_percentage is null
IFS=$'\t' read -r model fast effort ctx quota < <(echo "$input" | jq -r '
    ((.context_window.current_usage.input_tokens // .context_window.total_input_tokens // 0)
     + (.context_window.current_usage.cache_creation_input_tokens // 0)
     + (.context_window.current_usage.cache_read_input_tokens // 0)) as $t
    | (.context_window.used_percentage
       // (if (.context_window.context_window_size // 0) > 0
           then $t / .context_window.context_window_size * 100
           else null end)) as $c
    | [ (.model.display_name // "?"),
        (if .fast_mode then "⚡" else "-" end),
        (.effort.level // "-"),
        (if $c == null then "-" else (($c | floor | tostring) + "%") end),
        (if .rate_limits.five_hour.used_percentage
            then (.rate_limits.five_hour.used_percentage | floor | tostring) + "%"
            else "-" end)
      ] | @tsv')

# yellow past 80%, else dim (shared helper)
col() { if [ "${1%\%}" != "-" ] && [ "${1%\%}" -ge 80 ] 2>/dev/null; then printf '\033[1;33m'; else printf '\033[2m'; fi; }

out="${git_seg}  \033[2m${model}\033[0m"
[ "$fast" != "-" ] && out="${out}${fast}"
[ "$effort" != "-" ] && out="${out} \033[2m${effort}\033[0m"
out="${out}  $(col "$ctx")${ctx}\033[0m"
[ "$quota" != "-" ] && out="${out}  $(col "$quota")5h:${quota}\033[0m"

printf '%b ' "$out"
