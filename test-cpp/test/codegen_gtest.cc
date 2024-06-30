#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <cstdint>
#include <string_view>
#include <utility>

#include "gen/quicktype.h"
#include "gen/validator.h"

using namespace std::literals;
using quicktype::Animal;
using quicktype::fromJson;
using quicktype::toJson;
using validator::Validate;

struct Nothing {};

class CodegenFixture : public testing::Test {
protected:
    void SetUp() override { validator::globalInit(); }
    void TearDown() override { validator::globalDestroy(); }
};

TEST(Validator, NoInit)
{
    ASSERT_THAT([]() { Validate<Animal>(""); }, testing::ThrowsMessage<std::runtime_error>(
                                                    testing::HasSubstr("Could not find schema validator: '/animal'")));
}

TEST(Validator, WithInit)
{
    validator::globalInit();
    ASSERT_THAT([]() { Validate<Animal>(""); }, testing::ThrowsMessage<std::runtime_error>(
                                                    testing::HasSubstr("Failed to parse json string: Source error")));
    validator::globalDestroy();
}

TEST_F(CodegenFixture, Basic)
{
    const auto data = Animal{
        .name = "Tom",
        .nickname = "Tommy",
    };
    auto str = toJson(data).dump();
    ASSERT_EQ(R"({"age":0,"id":"cat","is-alive":false,"name":"Tom","nickname":"Tommy","type":"cat"})"sv, str);

    auto parsed = fromJson<Animal>(str);
    ASSERT_EQ(parsed.name, data.name);
    ASSERT_EQ(parsed.nickname, data.nickname);

    // Validate<Nothing>(str); // would not compile
}

TEST_F(CodegenFixture, NoRequireProp)
{
    EXPECT_THAT([]() { Validate<Animal>(R"--( {"age":0} )--"sv); },
                testing::ThrowsMessage<std::runtime_error>(
                    testing::HasSubstr("Data doesn't match schema '/animal': : Required property 'id' not found.")));
}
TEST_F(CodegenFixture, WrongId)
{
    EXPECT_THAT(
        []() { Validate<Animal>(R"({"age":0,"id":"CAT","is-alive":false,"name":"","nickname":"","type":"cat"})"sv); },
        testing::ThrowsMessage<std::runtime_error>(
            testing::HasSubstr("Data doesn't match schema '/animal': /id: 'CAT' is not a valid enum value.")));
}
