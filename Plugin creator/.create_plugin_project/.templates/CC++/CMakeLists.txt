cmake_minimum_required(VERSION {{CMAKE_VERSION}})

set(ANDROID_NDK "{{ANDROID_NDK}}")
set(CMAKE_TOOLCHAIN_FILE "${ANDROID_NDK}/build/cmake/android.toolchain.cmake")

set(ANDROID_ABI "{{DEFAULT_ABI}}")
set(ANDROID_PLATFORM "{{MIN_SDK}}")

set(CMAKE_MAKE_PROGRAM "{{NINJA}}" CACHE FILEPATH "Ninja executable")

set(CMAKE_SYSTEM_NAME Android)

set(CMAKE_C_COMPILER "${ANDROID_NDK}/toolchains/llvm/prebuilt/windows-x86_64/bin/clang.exe" CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER "${ANDROID_NDK}/toolchains/llvm/prebuilt/windows-x86_64/bin/clang++.exe" CACHE FILEPATH "CXX compiler")

project({{PLUGINNAME}} LANGUAGES C CXX)

set(CMAKE_BUILD_TYPE "Release")

add_library({{PLUGINNAME}} SHARED
    {{PLUGINNAME}}.c
    {{PLUGINNAME}}.cpp
)

target_link_libraries({{PLUGINNAME}} PRIVATE
    log
)

target_include_directories({{PLUGINNAME}} PRIVATE
    ${ANDROID_NDK}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include
)

target_compile_definitions({{PLUGINNAME}} PRIVATE
    ANDROID=1
)

target_compile_options({{PLUGINNAME}} PRIVATE
    -Wall
    -Wno-unused-parameter
)

message(STATUS "==========================================")
message(STATUS "Android NDK: ${ANDROID_NDK}")
message(STATUS "Android ABI: ${ANDROID_ABI}")
message(STATUS "Android Platform: ${ANDROID_PLATFORM}")
message(STATUS "Toolchain: ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "CXX Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Make program: ${CMAKE_MAKE_PROGRAM}")
message(STATUS "==========================================")