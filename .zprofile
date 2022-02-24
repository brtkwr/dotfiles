cd ~/Code
export GOPATH="/Users/brtknr/go/"
export PATH="$PATH:/Users/brtknr/Code/google-cloud-sdk/bin:/Users/brtknr/Code/skaffold/checkout-api/bin"
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
export CLOUDSDK_PYTHON="/opt/homebrew/bin/python3"

source ~/.secrets
