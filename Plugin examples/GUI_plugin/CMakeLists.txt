cmake_minimum_required(VERSION 4.0.3)

project("GUI_plugin")

add_library(GUI_plugin SHARED
    GUI_plugin.cpp
)

target_link_libraries(GUI_plugin
    log
)

set(NDK_PATH "D:/android-sdk/ndk/29.0.13599879")
include_directories(
    ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include
    ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include/android
)