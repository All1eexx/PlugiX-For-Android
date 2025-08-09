cmake_minimum_required(VERSION {{CMAKEVERSION}})
project("PLUGINNAME")

add_library(PLUGINNAME SHARED
  PLUGINNAME.c
)

target_link_libraries(PLUGINNAME
  log
)

set(NDK_PATH "{{android_ndk}}")
include_directories(
  ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include
  ${NDK_PATH}/toolchains/llvm/prebuilt/windows-x86_64/sysroot/usr/include/android
)
