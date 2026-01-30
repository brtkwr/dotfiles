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
source ~/Code/dotfiles/git-aliases.zsh

# Shell aliases and functions
# ------------------------------------------------------------------------------
source ~/Code/dotfiles/aliases.sh

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
