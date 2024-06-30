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

template<> void Validate<quicktype::Animal>(std::string_view data) { Validate("/animal", data); }
template<> void Validate<quicktype::EncodeTask>(std::string_view data) { Validate("/encode_task", data); }
template<> void Validate<quicktype::TransformTask>(std::string_view data) { Validate("/transform_task", data); }
template<> void Validate<quicktype::Vehicle>(std::string_view data) { Validate("/vehicle", data); }

}
