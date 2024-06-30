#!/usr/bin/env bash

set -eu -o pipefail

usage()
{
    local EXE=$(basename $0)
    cat <<-EOT
Create json-schema for 'schema-filename.yaml' with '\$id' set to '.\$id = schema-filename'.
All refererencies redirected from yaml files to 'new' schema ID's, i.e:
    from: {"\$ref": "/filename.yaml#inner-path"}
      to: {"\$ref": "/filename#inner-path"}
Some generators interpret '\$ref' as a schema name while the others as a file name. We generate
a 'schema-filename.json' and a hard link 'schema-filename' to avoid any generator complain.

Usage:
    $EXE [-q] [dir_in] [dir_out]

Options:
    -h,--help           Print this help
    --id                Add schema '\$id'
    dir_in              Path to schemas in yaml format (default: cwd)
    dir_out             Output path (default: cwd)

Example:
    $EXE transcoder out
EOT
}

entrypoint()
{
    local DIR_IN= DIR_OUT= GENERATE_ID=
    while [ $# -gt 0 ]; do
        local nargs=1
        case $1 in
            -h|--help) usage && return;;
            --id) GENERATE_ID=1;;
            *)  if [[ -z $DIR_IN ]]; then
                    DIR_IN=$1
                elif [[ -z $DIR_OUT ]]; then
                    DIR_OUT=$1
                else
                    echo "error: unrecognized option '$1'" >&2 && exit 1
                fi
            ;;
        esac
        shift $nargs
    done
    : ${DIR_IN:=.}
    : ${DIR_OUT:=.}

    local yamlFiles=$(cd "$DIR_IN" && find . -maxdepth 1 -name '*.yaml' | sort)
    if [[ -z "$yamlFiles" ]]; then
        echo "error: no '*.yaml' files found in '$DIR_IN' directory" >&2
        exit 1
    fi
    yamlFiles=$(basename -a $yamlFiles)

    yaml2json() {
        local yaml=$1 json= id=; shift
        yaml=${yaml#./}
        json=$DIR_OUT/$(dirname $yaml)
        json=${json%/.}
        mkdir -p "$json"
        json=$json/$(basename ${yaml%.*}.json)
        json=${json#./}

        [[ -z $GENERATE_ID ]] || id=$(basename --suffix=.json $json)
        # schema-filename.json       ---> {"$id":  "schema-filename"}
        # {"$ref": "filename.yaml#"} ---> {"$ref": "filename#"}
        <$DIR_IN/$yaml yq ${id:+'.$id = "'$id'"'} -o json |
            sed 's!\("$ref": "[^\#]\+\).yaml#!\1#!g' >$json

        # hard ref without 'json' extention
        ln $json ${json%.*}
    }
    local yaml=
    for yaml in $yamlFiles; do
        yaml2json $yaml &
    done
    wait-all
}

wait-all() { set -- $(jobs -p); for REPLY; do wait $REPLY; done; }

yq() { command yq --no-colors "$@"; }

SECONDS_START=$(date +%s)
ENTRYPOINT_POST_MESSAGE=done
entrypoint "$@"
echo "$(date +%H:%M:%S -u -d @$(( $(date +%s) - SECONDS_START ))) $ENTRYPOINT_POST_MESSAGE" >&2
