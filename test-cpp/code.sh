#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1

code .vscode.code-workspace
