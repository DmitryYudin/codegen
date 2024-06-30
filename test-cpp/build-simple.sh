#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1

DIR_BUILD=build

entrypoint()
{
    if ! command -v conan >/dev/null; then
        echo "error: conan not installed: 'pip3 install -q --user conan==1.64.1'" >&2 && exit 1
    fi


    [[ ${1:-} == c ]] && rm -rf -- $DIR_BUILD
    if [[ ! -d $DIR_BUILD/conan ]]; then
        if ! conan install -if $DIR_BUILD/conan --build=missing .; then
            echo "remove generated conan artifacts due to error above" >&2 # to restart next time
            rm -rf -- $DIR_BUILD/conan
            exit 1
        fi
    fi
    cmake -G Ninja -B $DIR_BUILD -S . -DCMAKE_BUILD_TYPE=Debug
    cmake --build $DIR_BUILD
}

SECONDS_START=$(date +%s)
ENTRYPOINT_POST_MESSAGE=done
entrypoint "$@"
echo "$(date +%H:%M:%S -u -d @$(( $(date +%s) - SECONDS_START ))) $ENTRYPOINT_POST_MESSAGE" >&2
