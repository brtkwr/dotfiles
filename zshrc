# Homebrew dynamic libraries — duplicated from .profile because macOS SIP
# strips DYLD_* vars before the shell starts. .profile sets it but SIP removes
# it; .zshrc runs after so this export actually sticks.
# See: https://hynek.me/articles/macos-dyld-env/
export DYLD_LIBRARY_PATH="/opt/homebrew/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}"

# Completion caching - only rebuild once a day for performance
# ------------------------------------------------------------------------------
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

# Starship prompt
# ------------------------------------------------------------------------------
eval "$(starship init zsh)"

# Git aliases (essential only)
# ------------------------------------------------------------------------------
source ~/Code/brtkwr/dotfiles/git-aliases.zsh

# Shell aliases and functions
# ------------------------------------------------------------------------------
source ~/Code/brtkwr/dotfiles/aliases.sh

# Fuzzy finder
# ------------------------------------------------------------------------------
eval "$(fzf --zsh)"

# Direnv
# ------------------------------------------------------------------------------
eval "$(direnv hook zsh)"

# google-cloud-sdk (completions only - PATH set in .profile)
# ------------------------------------------------------------------------------
source "$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"

# Docker CLI completions
# ------------------------------------------------------------------------------
fpath=(/Users/brtkwr/.docker/completions $fpath)

alias claude-mem='bun "/Users/brtkwr/.claude/plugins/cache/thedotmack/claude-mem/10.5.2/scripts/worker-service.cjs"'
alias claude='claude --permission-mode auto'
alias claude-yolo='claude --dangerously-skip-permissions'
alias dotfiles-doctor='~/Code/brtkwr/dotfiles/doctor.sh'

# Run dotfiles doctor once per day, only shows output on drift
if [[ -z "$CLAUDECODE" ]]; then
  stamp=~/.dotfiles-doctor-last
  if [[ ! -f $stamp ]] || (( $(date +%s) - $(stat -f %m "$stamp") > 86400 )); then
    ~/Code/brtkwr/dotfiles/doctor.sh >/tmp/dotfiles-doctor.log 2>&1
    [[ $? -ne 0 ]] && cat /tmp/dotfiles-doctor.log
    touch "$stamp"
  fi
fi

# Added by deepsource CLI (shell completions)
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/brtkwr/.lmstudio/bin"
# End of LM Studio CLI section

