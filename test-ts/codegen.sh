#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1

CODEGEN_DIR=../codegen
SCHEMAS_DIR=../schemas

rm -rf gen; mkdir -p gen

echo "Generate type declarations and validators"
$CODEGEN_DIR/codegen-ts.sh $SCHEMAS_DIR >gen/types.ts
