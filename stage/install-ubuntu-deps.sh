#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1 && . .config

: ${YQ_VERSION:=latest}

[[ $UID != 0 ]] && echo "error: please, run as root" >&2 && exit 1

apt() { apt-get -y "$@"; }
wget() { command wget -nv "$@"; }
github-latest-tag() { wget "https://api.github.com/repos/$1/$2/tags" -O- | grep '"name": "v[0-9]' | head -n1 | cut -d: -f2 | cut -d\" -f2; }

apt install wget ca-certificates

# v4.18+ https://github.com/mikefarah/yq/issues/1158
[[ $YQ_VERSION == latest ]] && YQ_VERSION=$(github-latest-tag mikefarah yq)
wget https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64.tar.gz -O- |
        tar --transform s/_linux_amd64// -xzf - -C /usr/local/bin ./yq_linux_amd64
if ! command -v ninja >/dev/null|| :; then
    NINJA_VERSION=$(github-latest-tag ninja-build ninja)
    wget https://github.com/ninja-build/ninja/releases/download/$NINJA_VERSION/ninja-linux.zip -O ninja-linux.zip
    unzip -o ninja-linux.zip -d /usr/local/bin
    rm -f ninja-linux.zip
fi
hash -r

cat <<EOT
-----------------------------------------------------------
$(wget --version | head -n 1)
$(yq --version)
ninja $(ninja --version)
-----------------------------------------------------------
EOT
