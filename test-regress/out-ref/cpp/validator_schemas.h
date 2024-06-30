#pragma once

#include <string_view>
#include <unordered_map>

namespace validator {
extern const std::unordered_map<std::string_view, const std::string_view> kSchemas;
}
