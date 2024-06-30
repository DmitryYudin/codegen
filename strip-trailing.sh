#!/usr/bin/env bash

set -eu -o pipefail
# && cd "$(dirname "$0")" >/dev/null 2>&1

for ext in md txt bash sh yaml yml json cmake c cpp cxx h hpp py; do
    find . -type f -iname "*.$ext" -exec sed -i -e's/[[:space:]]*$//' {} +
done
