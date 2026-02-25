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
