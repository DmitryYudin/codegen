cmake_minimum_required(VERSION 3.24)

project(codegen-test)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(bootstrap)
include(sanitizers)
include(conan)
include(gtest)

get_build_config_str(BUILD_CONFIG_STR)
get_testing_config_str(TESTING_CONFIG_STR)
get_sanitizers_config_str(SANITIZERS_CONFIG_STR)
message(NOTICE ===============================================================================)
message(NOTICE "${BUILD_CONFIG_STR} | ${SANITIZERS_CONFIG_STR} | ${TESTING_CONFIG_STR}")
message(NOTICE ===============================================================================)

# Targets
add_subdirectory(codegen)
if(BUILD_TESTING)
    add_subdirectory(test)
endif()
