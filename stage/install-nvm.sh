#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1 && . .config

: ${NVM_VERSION:=latest}
: ${NODE_VERSION:?not set}

wget() { command wget -nv "$@"; }
github-latest-tag() { wget "https://api.github.com/repos/$1/$2/tags" -O- | grep '"name": "v[0-9]' | head -n1 | cut -d: -f2 | cut -d\" -f2; }

if [[ ! -d ~/.nvm ]]; then
    [[ $NVM_VERSION == latest ]] && NVM_VERSION=$(github-latest-tag nvm-sh nvm)
    cat<<EOT
===========================================================
Install NVM: $NVM_VERSION
===========================================================
EOT
    wget https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh -O- | bash
    cat <<'EOT'
To make it works, please copy NVM related code from ~/.bashrc to ~/.profile
and restart shell
EOT
fi

. $NVM_DIR/nvm.sh

cat <<EOT
-----------------------------------------------------------
nvm $(nvm --version)
-----------------------------------------------------------
EOT
