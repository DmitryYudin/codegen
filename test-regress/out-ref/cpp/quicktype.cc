#include "quicktype.h"

#include <nlohmann/json.hpp>

namespace quicktype {

template <typename T>  nlohmann::json toJson(const T& t) { return nlohmann::json(t); }
template <typename T> T fromJson(std::string_view str) { return nlohmann::json::parse(str).get<T>();}

template nlohmann::json toJson(const Animal&);
template nlohmann::json toJson(const EncodeTask&);
template nlohmann::json toJson(const TransformTask&);
template nlohmann::json toJson(const Vehicle&);

template Animal fromJson<Animal>(std::string_view);
template EncodeTask fromJson<EncodeTask>(std::string_view);
template TransformTask fromJson<TransformTask>(std::string_view);
template Vehicle fromJson<Vehicle>(std::string_view);

}

