#!/bin/bash

set -eu -o pipefail

DIR_SCRIPT=$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)
case ${OS:-} in *_NT) DIR_SCRIPT=$(cygpath -m "$DIR_SCRIPT");; esac

DIR_TMP=${TMP:-/tmp}/_codegen/schemas_cpp
case ${OS:-} in *_NT) DIR_TMP=$(cygpath -m "$DIR_TMP");; esac
rm -rf "$DIR_TMP/"; mkdir -p "$DIR_TMP"

usage()
{
    local EXE=$(basename $0)
    cat <<-EOT
Generate c++ types and validators from schemas:
    quicktype.h
    validator.h
    validator.cc

Usage:
    $EXE PATH-TO-SCHEMAS [DIR-OUT]

Options:
    -h,--help           Print this help

    PATH-TO-SCHEMAS     Path to schemas in yaml format
    DIR-OUT             Output directory (default: cwd)

Dependencies:
    node install -g quicktype

Example:
    $EXE transcoder
EOT
}

entrypoint()
{
    [[ $# == 0 ]] && usage && exit 1

    local dirSchemas= dirOut=
    while [ $# -gt 0 ]; do
        local nargs=1
        case $1 in
            -h|--help) usage && return;;
            *)  [[ -z $dirSchemas ]] && dirSchemas=$1 && shift && continue
                [[ -z $dirOut ]] && dirOut=$1 && shift && continue
                echo "error: unrecognized option '$1'" >&2 && exit 1
            ;;
        esac
        shift $nargs
    done
    [[ -z $dirSchemas ]] && echo "error: schemas path not set" >&2 && exit 1
    : ${dirOut:=.}

    $DIR_SCRIPT/yaml2json.sh "$dirSchemas" $DIR_TMP

    mkdir -p $dirOut
    make_types $DIR_TMP $dirOut &
    make_validators $DIR_TMP $dirOut &
    wait-all
}

make_types()
{
    banner "Generate types"
    local dirIn=$1 dirOut=$2

    local jsonFiles=$(cd "$dirIn" && find . -maxdepth 1 -type f -not -name "*.json" | sort)
    jsonFiles=$(basename -a $jsonFiles)

    {
        cd $dirIn
        echo '// NOLINTBEGIN(*-forward-declaration-namespace)'
        quicktype \
            --lang c++ \
            --src-lang schema \
            --no-boost \
            --no-ignore-json-refs \
            --hide-null-optional \
            --code-format with-struct \
            --include-location global-include \
            --namespace quicktype \
            $jsonFiles |
        sed 's,std\:\:optional<T>(),std::nullopt,g'
        echo '// NOLINTEND(*-forward-declaration-namespace)'
        cd - >/dev/null
    } >$dirOut/quicktype.h

    local defs= defsTo= defsFrom= declTo= declFrom=
    for jsonFile in $jsonFiles; do
        local CamelCase=$(toCamelCase ${jsonFile%%.*})
        [[ $CamelCase == Definitions ]] && continue
        defs+="struct $CamelCase;"$'\n'
        defsTo+="template <> $CamelCase fromJson<$CamelCase>(std::string_view);"$'\n'
        defsFrom+="template <> nlohmann::json toJson(const $CamelCase&);"$'\n'
        declTo+="template nlohmann::json toJson(const $CamelCase&);"$'\n'
        declFrom+="template $CamelCase fromJson<$CamelCase>(std::string_view);"$'\n'
    done

    cat <<EOT >$dirOut/quicktype_fwd.h
#pragma once

#include <nlohmann/json_fwd.hpp>

// NOLINTBEGIN(*-forward-declaration-namespace)
namespace quicktype {

$defs
template <typename T> nlohmann::json toJson(const T&);
template <typename T> T fromJson(std::string_view);

$defsTo
$defsFrom
}
// NOLINTEND(*-forward-declaration-namespace)'
EOT

    cat <<EOT >$dirOut/quicktype.cc
#include "quicktype.h"

#include <nlohmann/json.hpp>

namespace quicktype {

template <typename T>  nlohmann::json toJson(const T& t) { return nlohmann::json(t); }
template <typename T> T fromJson(std::string_view str) { return nlohmann::json::parse(str).get<T>();}

$declTo
$declFrom
}

EOT
}

make_validators()
{
    banner "Generate validators"
    local dirIn=$1 dirOut=$2

    local jsonFiles=$(cd "$dirIn" && find . -maxdepth 1 -type f -not -name "*.json" | sort)
    jsonFiles=$(basename -a $jsonFiles)

    local schemas= declarations= definitions= name
    for name in $jsonFiles; do
        local CamelCase=$(toCamelCase $name)
        schemas+=$(cat<<EOT
    {
        "/$name",
        R"(
$(sed 's/^/            /' $dirIn/$name)
        )",
    },
EOT
)$'\n'
        [[ $CamelCase == Definitions ]] && continue

        definitions+="template<> void Validate<quicktype::$CamelCase>(std::string_view data) { Validate(\"/$name\", data); }"$'\n'
    done

cat<<EOT >$dirOut/validator.h
#pragma once

#include <string_view>

#include "quicktype_fwd.h"

namespace validator {

void globalInit();
void globalDestroy();
void Validate(std::string_view id, std::string_view data);
template <typename T> void Validate(std::string_view);

}
EOT

cat<<EOT >$dirOut/validator.cc
#include "validator.h"
#include "validator_schemas.h"

#include <list>
#include <string>
#include <string_view>
#include <unordered_map>

#include <fmt/ranges.h>
#include <jsoncons/json.hpp>
#include <jsoncons_ext/jsonschema/jsonschema.hpp>

using Json = jsoncons::json;
namespace jsonschema = jsoncons::jsonschema;

namespace validator {

namespace {
static std::unordered_map<std::string_view, jsonschema::json_validator<Json>> validators;
}

void globalInit() {
    auto resolver = [](const jsoncons::uri& uri) -> Json {
        const auto& id = uri.string();
        if (!kSchemas.count(id)) throw jsonschema::schema_error(fmt::format("Could not find schema: '{}'", id));
        const auto& schema = kSchemas.at(id);
        return Json::parse(schema);
    };
    for (const auto& [id, schema] : kSchemas) {
        auto validator = jsonschema::make_schema(Json::parse(schema), resolver);
        validators.emplace(id, std::move(validator));
    }
}

void globalDestroy() {
    validators.clear();
}

void Validate(std::string_view id, std::string_view data)
{
    if (!validators.count(id))
        throw jsoncons::jsonschema::schema_error(fmt::format("Could not find schema validator: '{}'", id));
    const auto& validator = validators.at(id);

    std::list<std::string> errors;
    validator.validate(Json::parse(data), [&errors](const auto& o) {
        errors.push_back(fmt::format("{}: {}", o.instance_location(), o.message()));
    });
    if (!errors.empty())
        throw jsonschema::schema_error(fmt::format("Data doesn't match schema '{}': {}", id, fmt::join(errors, "\n")));
}

$definitions
}
EOT

cat <<EOT >$dirOut/validator_schemas.h
#pragma once

#include <string_view>
#include <unordered_map>

namespace validator {
extern const std::unordered_map<std::string_view, const std::string_view> kSchemas;
}
EOT

cat <<EOT >$dirOut/validator_schemas.cc
#include "validator_schemas.h"

namespace validator {
extern const std::unordered_map<std::string_view, const std::string_view> kSchemas = {
$schemas
};
}
EOT

}

banner() {
    echo "#######################################################"
    echo "# $*"
    echo "#######################################################"
} >&2

wait-all() { set -- $(jobs -p); for REPLY; do wait $REPLY; done; }
npx() { command npx --no -- "$@"; }
quicktype() { npx quicktype "$@"; }
toCamelCase() { echo "$1" | sed 's,^\([a-z]\),\U\1,g;s,[_-]\([a-z]\),\U\1,g'; }

SECONDS_START=$(date +%s)
ENTRYPOINT_POST_MESSAGE=done
entrypoint "$@"
echo "$(date +%H:%M:%S -u -d @$(( $(date +%s) - SECONDS_START ))) $ENTRYPOINT_POST_MESSAGE" >&2
