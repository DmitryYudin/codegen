#pragma once

#include <nlohmann/json_fwd.hpp>

// NOLINTBEGIN(*-forward-declaration-namespace)
namespace quicktype {

struct Animal;
struct EncodeTask;
struct TransformTask;
struct Vehicle;

template <typename T> nlohmann::json toJson(const T&);
template <typename T> T fromJson(std::string_view);

template <> Animal fromJson<Animal>(std::string_view);
template <> EncodeTask fromJson<EncodeTask>(std::string_view);
template <> TransformTask fromJson<TransformTask>(std::string_view);
template <> Vehicle fromJson<Vehicle>(std::string_view);

template <> nlohmann::json toJson(const Animal&);
template <> nlohmann::json toJson(const EncodeTask&);
template <> nlohmann::json toJson(const TransformTask&);
template <> nlohmann::json toJson(const Vehicle&);

}
// NOLINTEND(*-forward-declaration-namespace)'
