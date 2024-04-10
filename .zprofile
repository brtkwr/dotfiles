cd Code
export GOPATH="$HOME/go/"
export PATH="$PATH:$HOME/google-cloud-sdk/bin:/Applications/Docker.app/Contents/Resources/bin"
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
eval "$(/opt/homebrew/bin/brew shellenv)"

# Stern
alias sternx="stern -o raw -i 'event'"
alias jqx="jq -r '.severity + \" | \" + .event'"

# Python 3.10 support
export PATH="/opt/homebrew/opt/python@3.10/bin:$PATH"
export PKG_CONFIG_PATH="/opt/homebrew/opt/python@3.10/lib/pkgconfig"
export LDFLAGS="-L/opt/homebrew/opt/python@3.10/lib"
export LDFLAGS="$LDFLAGS -L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
export CLOUDSDK_PYTHON="python3"

export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1

# Automatically source venv for tillit CLI
export AUTO_VIRTUAL_ENV=true

# Shortcut for VSCode
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# Rust
source "$HOME/.cargo/env"

# Grab secret from GCP
function gcpsecret () {
    gcloud secrets versions access latest --secret=$1 --project=$2
}

# Usage: kube <cluster> <namespace>
function kube() {
    kubectx ${1:-"-c"}
    kubens ${2:-}
}

# Kubectl
alias k="kubectl"

# Use new GKE auth plugin
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Source secrets
source ~/.secrets

# To be able to sign commits
export GPG_TTY=$(tty)

# Terraform args
export TF_CLI_ARGS_plan="-parallelism=50"
export TF_CLI_ARGS_apply="-parallelism=50"

# Fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
