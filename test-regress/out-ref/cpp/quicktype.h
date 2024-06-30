// NOLINTBEGIN(*-forward-declaration-namespace)
//  To parse this JSON data, first install
//
//      json.hpp  https://github.com/nlohmann/json
//
//  Then include this file, and then do
//
//     Animal data = nlohmann::json::parse(jsonString);
//     Definitions data = nlohmann::json::parse(jsonString);
//     EncodeTask data = nlohmann::json::parse(jsonString);
//     TransformTask data = nlohmann::json::parse(jsonString);
//     Vehicle data = nlohmann::json::parse(jsonString);

#pragma once

#include <optional>
#include <nlohmann/json.hpp>

#ifndef NLOHMANN_OPT_HELPER
#define NLOHMANN_OPT_HELPER
namespace nlohmann {
    template <typename T>
    struct adl_serializer<std::shared_ptr<T>> {
        static void to_json(json & j, const std::shared_ptr<T> & opt) {
            if (!opt) j = nullptr; else j = *opt;
        }

        static std::shared_ptr<T> from_json(const json & j) {
            if (j.is_null()) return std::make_shared<T>(); else return std::make_shared<T>(j.get<T>());
        }
    };
    template <typename T>
    struct adl_serializer<std::optional<T>> {
        static void to_json(json & j, const std::optional<T> & opt) {
            if (!opt) j = nullptr; else j = *opt;
        }

        static std::optional<T> from_json(const json & j) {
            if (j.is_null()) return std::make_optional<T>(); else return std::make_optional<T>(j.get<T>());
        }
    };
}
#endif

namespace quicktype {
    using nlohmann::json;

    #ifndef NLOHMANN_UNTYPED_quicktype_HELPER
    #define NLOHMANN_UNTYPED_quicktype_HELPER
    inline json get_untyped(const json & j, const char * property) {
        if (j.find(property) != j.end()) {
            return j.at(property).get<json>();
        }
        return json();
    }

    inline json get_untyped(const json & j, std::string property) {
        return get_untyped(j, property.data());
    }
    #endif

    #ifndef NLOHMANN_OPTIONAL_quicktype_HELPER
    #define NLOHMANN_OPTIONAL_quicktype_HELPER
    template <typename T>
    inline std::shared_ptr<T> get_heap_optional(const json & j, const char * property) {
        auto it = j.find(property);
        if (it != j.end() && !it->is_null()) {
            return j.at(property).get<std::shared_ptr<T>>();
        }
        return std::shared_ptr<T>();
    }

    template <typename T>
    inline std::shared_ptr<T> get_heap_optional(const json & j, std::string property) {
        return get_heap_optional<T>(j, property.data());
    }
    template <typename T>
    inline std::optional<T> get_stack_optional(const json & j, const char * property) {
        auto it = j.find(property);
        if (it != j.end() && !it->is_null()) {
            return j.at(property).get<std::optional<T>>();
        }
        return std::nullopt;
    }

    template <typename T>
    inline std::optional<T> get_stack_optional(const json & j, std::string property) {
        return get_stack_optional<T>(j, property.data());
    }
    #endif

    enum class Id : int { CAT, DOG };

    struct Animal {
        std::optional<std::string> account;
        int64_t age;
        std::optional<std::vector<std::string>> awards;
        std::optional<double> height;
        Id id;
        bool is_alive;
        std::string name;
        std::optional<std::string> nickname;
        Id type;
        std::optional<double> weight;
    };

    struct Definitions {
    };

    enum class Provider : int { FS, S3 };

    struct FileAddr {
        std::string file_uri;
        Provider provider;
        std::optional<std::string> bucket;
        std::optional<std::string> host_uri;
        std::optional<std::string> s3_region;
    };

    struct EncodeTask {
        std::optional<int64_t> bitrate;
        FileAddr destination;
        std::map<std::string, std::string> options;
        FileAddr source;
        std::string task_id;
    };

    struct Transform {
        double angle;
        double x;
        double y;
    };

    struct TransformTask {
        FileAddr destination;
        FileAddr source;
        std::string task_id;
        std::optional<Transform> transform;
    };

    struct Driver {
        std::string id;
        std::string name;
    };

    enum class Type : int { BICYCLE, CAR, TRUCK };

    struct Vehicle {
        std::vector<Driver> drivers;
        std::string id;
        std::map<std::string, std::string> props;
        Type type;
    };
}

namespace quicktype {
    void from_json(const json & j, Animal & x);
    void to_json(json & j, const Animal & x);

    void from_json(const json & j, Definitions & x);
    void to_json(json & j, const Definitions & x);

    void from_json(const json & j, FileAddr & x);
    void to_json(json & j, const FileAddr & x);

    void from_json(const json & j, EncodeTask & x);
    void to_json(json & j, const EncodeTask & x);

    void from_json(const json & j, Transform & x);
    void to_json(json & j, const Transform & x);

    void from_json(const json & j, TransformTask & x);
    void to_json(json & j, const TransformTask & x);

    void from_json(const json & j, Driver & x);
    void to_json(json & j, const Driver & x);

    void from_json(const json & j, Vehicle & x);
    void to_json(json & j, const Vehicle & x);

    void from_json(const json & j, Id & x);
    void to_json(json & j, const Id & x);

    void from_json(const json & j, Provider & x);
    void to_json(json & j, const Provider & x);

    void from_json(const json & j, Type & x);
    void to_json(json & j, const Type & x);

    inline void from_json(const json & j, Animal& x) {
        x.account = get_stack_optional<std::string>(j, "account");
        x.age = j.at("age").get<int64_t>();
        x.awards = get_stack_optional<std::vector<std::string>>(j, "awards");
        x.height = get_stack_optional<double>(j, "height");
        x.id = j.at("id").get<Id>();
        x.is_alive = j.at("is-alive").get<bool>();
        x.name = j.at("name").get<std::string>();
        x.nickname = get_stack_optional<std::string>(j, "nickname");
        x.type = j.at("type").get<Id>();
        x.weight = get_stack_optional<double>(j, "weight");
    }

    inline void to_json(json & j, const Animal & x) {
        j = json::object();
        if (x.account) {
            j["account"] = x.account;
        }
        j["age"] = x.age;
        if (x.awards) {
            j["awards"] = x.awards;
        }
        if (x.height) {
            j["height"] = x.height;
        }
        j["id"] = x.id;
        j["is-alive"] = x.is_alive;
        j["name"] = x.name;
        if (x.nickname) {
            j["nickname"] = x.nickname;
        }
        j["type"] = x.type;
        if (x.weight) {
            j["weight"] = x.weight;
        }
    }

    inline void from_json(const json & j, Definitions& x) {
    }

    inline void to_json(json & j, const Definitions & x) {
        j = json::object();
    }

    inline void from_json(const json & j, FileAddr& x) {
        x.file_uri = j.at("file_uri").get<std::string>();
        x.provider = j.at("provider").get<Provider>();
        x.bucket = get_stack_optional<std::string>(j, "bucket");
        x.host_uri = get_stack_optional<std::string>(j, "host_uri");
        x.s3_region = get_stack_optional<std::string>(j, "s3_region");
    }

    inline void to_json(json & j, const FileAddr & x) {
        j = json::object();
        j["file_uri"] = x.file_uri;
        j["provider"] = x.provider;
        if (x.bucket) {
            j["bucket"] = x.bucket;
        }
        if (x.host_uri) {
            j["host_uri"] = x.host_uri;
        }
        if (x.s3_region) {
            j["s3_region"] = x.s3_region;
        }
    }

    inline void from_json(const json & j, EncodeTask& x) {
        x.bitrate = get_stack_optional<int64_t>(j, "bitrate");
        x.destination = j.at("destination").get<FileAddr>();
        x.options = j.at("options").get<std::map<std::string, std::string>>();
        x.source = j.at("source").get<FileAddr>();
        x.task_id = j.at("task_id").get<std::string>();
    }

    inline void to_json(json & j, const EncodeTask & x) {
        j = json::object();
        if (x.bitrate) {
            j["bitrate"] = x.bitrate;
        }
        j["destination"] = x.destination;
        j["options"] = x.options;
        j["source"] = x.source;
        j["task_id"] = x.task_id;
    }

    inline void from_json(const json & j, Transform& x) {
        x.angle = j.at("angle").get<double>();
        x.x = j.at("x").get<double>();
        x.y = j.at("y").get<double>();
    }

    inline void to_json(json & j, const Transform & x) {
        j = json::object();
        j["angle"] = x.angle;
        j["x"] = x.x;
        j["y"] = x.y;
    }

    inline void from_json(const json & j, TransformTask& x) {
        x.destination = j.at("destination").get<FileAddr>();
        x.source = j.at("source").get<FileAddr>();
        x.task_id = j.at("task_id").get<std::string>();
        x.transform = get_stack_optional<Transform>(j, "transform");
    }

    inline void to_json(json & j, const TransformTask & x) {
        j = json::object();
        j["destination"] = x.destination;
        j["source"] = x.source;
        j["task_id"] = x.task_id;
        if (x.transform) {
            j["transform"] = x.transform;
        }
    }

    inline void from_json(const json & j, Driver& x) {
        x.id = j.at("id").get<std::string>();
        x.name = j.at("name").get<std::string>();
    }

    inline void to_json(json & j, const Driver & x) {
        j = json::object();
        j["id"] = x.id;
        j["name"] = x.name;
    }

    inline void from_json(const json & j, Vehicle& x) {
        x.drivers = j.at("drivers").get<std::vector<Driver>>();
        x.id = j.at("id").get<std::string>();
        x.props = j.at("props").get<std::map<std::string, std::string>>();
        x.type = j.at("type").get<Type>();
    }

    inline void to_json(json & j, const Vehicle & x) {
        j = json::object();
        j["drivers"] = x.drivers;
        j["id"] = x.id;
        j["props"] = x.props;
        j["type"] = x.type;
    }

    inline void from_json(const json & j, Id & x) {
        if (j == "cat") x = Id::CAT;
        else if (j == "dog") x = Id::DOG;
        else { throw std::runtime_error("Input JSON does not conform to schema!"); }
    }

    inline void to_json(json & j, const Id & x) {
        switch (x) {
            case Id::CAT: j = "cat"; break;
            case Id::DOG: j = "dog"; break;
            default: throw std::runtime_error("Unexpected value in enumeration \"[object Object]\": " + std::to_string(static_cast<int>(x)));
        }
    }

    inline void from_json(const json & j, Provider & x) {
        if (j == "fs") x = Provider::FS;
        else if (j == "s3") x = Provider::S3;
        else { throw std::runtime_error("Input JSON does not conform to schema!"); }
    }

    inline void to_json(json & j, const Provider & x) {
        switch (x) {
            case Provider::FS: j = "fs"; break;
            case Provider::S3: j = "s3"; break;
            default: throw std::runtime_error("Unexpected value in enumeration \"[object Object]\": " + std::to_string(static_cast<int>(x)));
        }
    }

    inline void from_json(const json & j, Type & x) {
        if (j == "bicycle") x = Type::BICYCLE;
        else if (j == "car") x = Type::CAR;
        else if (j == "truck") x = Type::TRUCK;
        else { throw std::runtime_error("Input JSON does not conform to schema!"); }
    }

    inline void to_json(json & j, const Type & x) {
        switch (x) {
            case Type::BICYCLE: j = "bicycle"; break;
            case Type::CAR: j = "car"; break;
            case Type::TRUCK: j = "truck"; break;
            default: throw std::runtime_error("Unexpected value in enumeration \"[object Object]\": " + std::to_string(static_cast<int>(x)));
        }
    }
}
// NOLINTEND(*-forward-declaration-namespace)
