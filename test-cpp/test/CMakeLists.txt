add_executable(codegen-gtest codegen_gtest.cc)

target_link_libraries(codegen-gtest CONAN_PKG::gtest codegen)

add_test(NAME codegen-gtest COMMAND codegen-gtest)
