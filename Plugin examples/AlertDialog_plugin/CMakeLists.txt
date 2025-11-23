cmake_minimum_required(VERSION 4.0.3)

project("AlertDialog_plugin")

add_library(AlertDialog_plugin SHARED
    AlertDialog_plugin.c
)

target_link_libraries(AlertDialog_plugin
    log
)

set(NDK_PATH "D:/android-sdk/ndk/29.0.13599879")
include_directories(
    ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include
    ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include/android
)