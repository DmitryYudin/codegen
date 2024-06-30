#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1 && . .config

: ${NVM_DIR:?not set, please install NVM}
: ${JSON_SCHEMA_TO_TYPESCRIPT_VERSION:?not set}

. $NVM_DIR/nvm.sh

cat<<EOT
===========================================================
Install global node packages
===========================================================
EOT

npm install -g --progress=false npm@latest
npm install -g --progress=false \
    eslint \
    quicktype ajv ajv-cli json-schema-to-typescript@$JSON_SCHEMA_TO_TYPESCRIPT_VERSION

npm list -g --depth=0

