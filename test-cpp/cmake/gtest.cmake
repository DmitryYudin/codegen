if(PROJECT_IS_TOP_LEVEL)
    option(BUILD_TESTING "Enable/Disable testing" ON)
else()
    option(BUILD_TESTING "Enable/Disable testing" OFF)
endif()

if(BUILD_TESTING)
    enable_testing()
    include(GoogleTest)
endif()

###############################################################################
# Pretty print testing configuration
###############################################################################
function(get_testing_config_str var)
    if(BUILD_TESTING)
        set(INFO "test")
    else()
        set(INFO "no-test")
    endif()
    set(${var} ${INFO} PARENT_SCOPE)
endfunction()
