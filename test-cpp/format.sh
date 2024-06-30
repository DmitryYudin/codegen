#!/usr/bin/env bash

set -eu -o pipefail && cd "$(dirname "$0")" >/dev/null 2>&1

DIRS='src test'
FILE_EXT=(c cc cpp cxx h hpp hxx)

inames=${FILE_EXT[@]/#/-o -iname *.}
inames=${inames#-o} # remove very first '-o'

clang-format() { command clang-format-14 -i ${LINT_STRICT:+--Werror --dry-run} --style=file:.clang-format "$@"; }
for REPLY in $DIRS; do [[ -d $REPLY ]] && clang-format $(find $REPLY -type f $inames); done
