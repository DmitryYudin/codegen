#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1

CODEGEN_DIR=../codegen
SCHEMAS_DIR=../schemas

entrypoint()
{
    rm -rf -- out

    $CODEGEN_DIR/codegen-cpp.sh $SCHEMAS_DIR out/cpp
    $CODEGEN_DIR/codegen-ts.sh $SCHEMAS_DIR >out/out.ts

    echo "#######################################################"
    echo "# Compare result"
    echo "#######################################################"
    for REPLY in $(find out -type f); do diff $REPLY ${REPLY/#out/out-ref}; done
    local ref=$(find out -type f)
    local gen=$(find out -type f)
    if [[ $ref != $gen ]]; then
        # Ooops: align left if 'ref' list shorter than 'gen'
        echo "error: expect reference file set to equal to generated:"
        paste -d $'\t'  <(echo "$ref" | sort) <(echo "$gen" | sort) | column -t
        exit 1
    fi >&2
    rm -rf -- out

    ENTRYPOINT_POST_MESSAGE='done, test passed'
}

SECONDS_START=$(date +%s)
ENTRYPOINT_POST_MESSAGE=done
entrypoint "$@"
echo "$(date +%H:%M:%S -u -d @$(( $(date +%s) - SECONDS_START ))) $ENTRYPOINT_POST_MESSAGE" >&2
