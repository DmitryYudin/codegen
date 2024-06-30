#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1 && . .config

: ${NVM_DIR:?not set, please install NVM}
: ${NODE_VERSION:?not set}

. $NVM_DIR/nvm.sh

cat<<EOT
===========================================================
Install Node: $NODE_VERSION
===========================================================
EOT
nvm install $NODE_VERSION
nvm use $NODE_VERSION
npm config set -g loglevel=error
npm config set -g fund=false
npm config list

cat <<EOT
-----------------------------------------------------------
node $(node --version)
npm $(npm --version)
-----------------------------------------------------------
EOT
