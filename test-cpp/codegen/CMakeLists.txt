set(CODEGEN_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../codegen)
set(SCHEMAS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../schemas)
file(GLOB_RECURSE CODEGEN_DEPS
    ${CODEGEN_DIR}/*.sh
    ${SCHEMAS_DIR}/*.yaml)
set(GENERATED_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/gen/quicktype.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/gen/quicktype.h
    ${CMAKE_CURRENT_SOURCE_DIR}/gen/validator.h
    ${CMAKE_CURRENT_SOURCE_DIR}/gen/validator.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/gen/validator_schemas.h
    ${CMAKE_CURRENT_SOURCE_DIR}/gen/validator_schemas.cc
)
add_custom_command(
    COMMENT "Generate C++ types and validators into ${CMAKE_CURRENT_SOURCE_DIR}/gen directory"
    OUTPUT ${GENERATED_SRC}
    DEPENDS ${CODEGEN_DEPS}
    COMMAND ${CMAKE_COMMAND} -E rm -rf ${CMAKE_CURRENT_SOURCE_DIR}/gen
    COMMAND ${CODEGEN_DIR}/codegen-cpp.sh ${SCHEMAS_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/gen
    USES_TERMINAL
)
add_library(codegen STATIC ${GENERATED_SRC})
target_include_directories(codegen PUBLIC .)
target_link_libraries(codegen PUBLIC
    CONAN_PKG::jsoncons
    CONAN_PKG::fmt
    CONAN_PKG::nlohmann_json
)
