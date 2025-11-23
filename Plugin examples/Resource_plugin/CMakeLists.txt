cmake_minimum_required(VERSION 4.0.3)

project("Resource_plugin")

find_library(ANDROID_LIB android)

add_library(Resource_plugin SHARED
    Resource_plugin.cpp
)

target_link_libraries(Resource_plugin
    log
    ${ANDROID_LIB}
)

set(NDK_PATH "D:/android-sdk/ndk/29.0.13599879")
include_directories(
    ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include
    ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include/android
)