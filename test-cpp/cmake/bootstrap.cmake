#
# This file defines two pairs of macro: {x86, x64} and {ARM, ARM64} based on toolchain settings.
#
# CMAKE_SYSTEM_NAME - Valid names can be identified from the content of 'Modules/Platform' folder: AIX, Android, Apple, ...
#           as well as a set of available compilers visible throught 'Platform/{CMAKE_SYSTEM_NAME}-${CompilerId}' files.
# The most usefull 'CMAKE_SYSTEM_NAME's to match 'Build.gn' are:
#           android <=> Android
#             linux <=> Linux
#               win <=> Windows
#               ios <=> iOS
#               mac <=> Darwin
#               ??? <=> tvOS, watchOS
#
# A set of supported languages are given by 'Modules/CMakeDetermine${Lang}Compiler.cmake' files: ASM-ATT ASM_MASM ASM_NASM ASM
#           C CSharp CUDA CXX Fortran HIP ISPC Java OBJC OBJCXX RC Swift
#
# The are lot of compilers supported (see 'Modules/CMakeCompilerIdDetection.cmake'): ADSP AppleClang ARMCC ARMClang Borland Bruce
#           Clang Comeau Compaq Cray Embarcadero Fujitsu FujitsuClang GHS GNU HP IAR Intel IntelLLVM NVHPC NVIDIA MSVC OpenWatcom
#           PathScale PGI SCO SDCC SunPro TI TinyCC VisualAge Watcom XL XLClang zOS
#
# https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/How-To-Write-Platform-Checks:
# (old school, "soft" deprecated)
#           UNIX   : is TRUE on all UNIX-like OS's, including Apple OS X and CygWin
#           WIN32  : is TRUE on Windows. Prior to 2.8.4 this included CygWin
#           APPLE  : is TRUE on Apple systems. Note this does not imply the system is Mac OS X,
#                    only that APPLE is #defined in C/C++ header files.
#           MINGW  : is TRUE when using the MinGW compiler in Windows
#           MSYS   : is TRUE when using the MSYS developer environment in Windows
#           CYGWIN : is TRUE on Windows when using the CygWin version of cmake
#
option(ENABLE_WARN_ALL "Enable all warnings (aka -Wall)" ON)
option(ENABLE_WARN_EXTRA "Enable all warnings (aka -Wextra)" OFF)

###############################################################################
# Set build type
###############################################################################
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
if (CMAKE_CONFIGURATION_TYPES AND CMAKE_BUILD_TYPE) # https://stackoverflow.com/questions/31661264/cmake-generators-for-visual-studio-do-not-set-cmake-configuration-types
    set(CMAKE_CONFIGURATION_TYPES "${CMAKE_BUILD_TYPE}" CACHE STRING "${CMAKE_BUILD_TYPE} only" FORCE)
endif()

###############################################################################
# System architecture detection based on $CMAKE_SYSTEM_PROCESSOR value:
#   X86+X(32|64) or ARM+ARM(32|64) variables
###############################################################################
function(define_achitecture_vars)
    set(X86_ALIASES x86 i386 i686 x86_64 amd64)
    set(ARM_ALIASES armeabi-v7a armv7-a aarch64 arm64-v8a)

    string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" sysproc)
    list(FIND X86_ALIASES "${sysproc}" X86_MATCH)
    list(FIND ARM_ALIASES "${sysproc}" ARM_MATCH)
    if ("${sysproc}" STREQUAL "" OR X86_MATCH GREATER "-1")
        set(X86 1 PARENT_SCOPE)
        set(X64 0 PARENT_SCOPE)
        if ("${CMAKE_SIZEOF_VOID_P}" MATCHES 8)
            set(X64 1 PARENT_SCOPE)
        endif()
    elseif (ARM_MATCH GREATER "-1")
        set(ARM 1)
        set(ARM64 0 PARENT_SCOPE)
        if ("${CMAKE_SIZEOF_VOID_P}" MATCHES 8)
            set(ARM64 1 PARENT_SCOPE)
        endif()
    else()
        message(FATAL_ERROR "CMAKE_SYSTEM_PROCESSOR value `${CMAKE_SYSTEM_PROCESSOR}` is unknown\n"
                            "Please add this value near ${CMAKE_CURRENT_LIST_FILE}:${CMAKE_CURRENT_LIST_LINE}")
    endif()
endfunction()

###############################################################################
# Pretty print current build configuration
###############################################################################
function(get_build_config_str var)
    # https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html
    string(REGEX MATCH "^[0-9]+\\.[0-9]+" compiler_ver "${CMAKE_C_COMPILER_VERSION}")
    set(target "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
    if (CMAKE_C_COMPILER_FRONTEND_VARIANT)
        set(compiler "${CMAKE_C_COMPILER_ID}-${compiler_ver}/${CMAKE_C_COMPILER_FRONTEND_VARIANT}")
    else()
        set(compiler "${CMAKE_C_COMPILER_ID}-${compiler_ver}")
    endif()
    set(runtime "${CMAKE_C_PLATFORM_ID}")
    if(X86)
        set(platform "X86=${X86} X64=${X64}")
    endif()
    if(ARM)
        set(platform "ARM=${ARM} ARM64=${ARM64}")
    endif()
    set(INFO "${CMAKE_BUILD_TYPE}@${target} | ${compiler} [${runtime}] | ${platform}")
    set(${var} ${INFO} PARENT_SCOPE)
endfunction()

###############################################################################
# Tune OS specific flags
###############################################################################
if ("Windows" STREQUAL CMAKE_SYSTEM_NAME)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    add_compile_definitions(_SCL_SECURE_NO_WARNINGS)
    add_compile_definitions(_SILENCE_CXX20_CISO646_REMOVED_WARNING)
    add_compile_definitions(NOMINMAX)
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
    add_compile_definitions(_FILE_OFFSET_BITS=64)
    add_compile_definitions(_LARGEFILE64_SOURCE)
    add_compile_definitions(_LARGEFILE_SOURCE)
endif()
if ("MinGW" STREQUAL CMAKE_C_PLATFORM_ID)         # https://sourceforge.net/p/mingw-w64/mailman/message/29128250/
    add_compile_definitions(__USE_MINGW_ANSI_STDIO)
endif()
if ("Android" STREQUAL CMAKE_SYSTEM_NAME AND    # Here the 'toolchain.cmake' file from the Android-NDK bundle is in use. CMake pass both
    "Clang"   STREQUAL CMAKE_C_COMPILER_ID)     # CFLAGS and ASMFLAGS to asm-compiler and this makes Clang complain for unknown flags.
    set(CMAKE_ASM_FLAGS "-Wno-unused-command-line-argument ${CMAKE_ASM_FLAGS}")
endif()

###############################################################################
# Set warnings level
###############################################################################
if ("MSVC" STREQUAL CMAKE_C_COMPILER_ID OR "MSVC" STREQUAL CMAKE_C_COMPILER_FRONTEND_VARIANT)
    string(REGEX REPLACE "[-/]W[1-4]" "" CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}")
    string(REGEX REPLACE "[-/]W[1-4]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    if (ENABLE_WARN_EXTRA)
        add_compile_options(/W4)
    elseif (ENABLE_WARN_ALL)
        add_compile_options(/W3)
    endif()
endif()
if ("GNU" STREQUAL CMAKE_C_COMPILER_ID OR "GNU" STREQUAL CMAKE_C_COMPILER_FRONTEND_VARIANT)
    if (ENABLE_WARN_ALL)
        add_compile_options(-Wall)
    endif()
    if (ENABLE_WARN_EXTRA)
        add_compile_options(-Wextra)
    endif()
    add_compile_options(-Wno-comment)
endif()

###############################################################################
# Set debug info
###############################################################################
if ("GNU" STREQUAL CMAKE_C_COMPILER_ID OR "GNU" STREQUAL CMAKE_C_COMPILER_FRONTEND_VARIANT)
    add_compile_options(-gdwarf-4)
    add_compile_options($<$<CONFIG:MinSizeRel>:-ggdb1>)
    add_compile_options($<$<CONFIG:Release>:-ggdb2>)
    add_compile_options($<$<CONFIG:RelWithDebInfo>:-ggdb3>)
    add_compile_options($<$<CONFIG:Debug>:-ggdb3>)
endif()

###############################################################################
# Tune default compiler flags
###############################################################################
if ("MSVC" STREQUAL CMAKE_C_COMPILER_ID OR "MSVC" STREQUAL CMAKE_C_COMPILER_FRONTEND_VARIANT)
    add_compile_options(-Zc:__cplusplus)
    add_compile_options($<$<CONFIG:Release>:/Gy>)
    add_link_options($<$<CONFIG:Release>:/OPT:REF>)  # eleminate unreferenced functions
    add_link_options($<$<CONFIG:Release>:/OPT:ICF>)  # identical block folding
    # enable stack trace in release, generate symbol info
    string(REGEX REPLACE "/Zi" "" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
    add_compile_options($<$<CONFIG:Release>:/Zi>)
    add_compile_options($<$<CONFIG:RelWithDebInfo>:/ZI>)
    add_link_options($<$<CONFIG:Release>:/DEBUG:fastlink>) # keep symbol info
    #if (X86)
    #    add_compile_options(/arch:AVX2)
    #endif()
endif()
if ("GNU" STREQUAL CMAKE_C_COMPILER_ID OR "GNU" STREQUAL CMAKE_C_COMPILER_FRONTEND_VARIANT)
    #if (X86)
    #    add_compile_options(-mavx2)
    #endif ()
    add_compile_definitions(__STDC_WANT_LIB_EXT1__=1)
    if (CYGWIN)
        add_compile_definitions(_GNU_SOURCE)
    endif ()
    add_compile_options(-fno-omit-frame-pointer)
    # add_link_options($<$<CONFIG:Release>:-s>)     # strip RELEASE executables
endif()
if ("Intel" STREQUAL CMAKE_C_COMPILER_ID)           # ICC has different options format for Windows and Linux build.
    if("Windows" STREQUAL CMAKE_HOST_SYSTEM_NAME)
        add_compile_options(/Qrestrict)
        add_compile_options(/Qdiag-disable:167)     # "TYPE (*)[N]" is incompatible with parameter of type "const TYPE (*)[N]"
    else()
        add_compile_options(-restrict)
        add_compile_options(-diag-disable=167)
    endif()
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
if (Darwin STREQUAL CMAKE_SYSTEM_NAME)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
endif()

define_achitecture_vars()
