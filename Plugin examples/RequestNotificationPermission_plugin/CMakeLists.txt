cmake_minimum_required(VERSION 4.0.3)

project("RequestNotificationPermission_plugin")

add_library(RequestNotificationPermission_plugin SHARED
    RequestNotificationPermission_plugin.cpp
)

target_link_libraries(RequestNotificationPermission_plugin
    log
)

set(NDK_PATH "D:/android-sdk/ndk/29.0.13599879")
include_directories(
    ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include
    ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include/android
)