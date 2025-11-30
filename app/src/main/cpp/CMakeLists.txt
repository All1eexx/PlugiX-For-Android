cmake_minimum_required(VERSION 4.1.2)

project("plugin_loader")

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(plugin_loader SHARED
        plugin_loader.cpp
)

target_link_libraries(plugin_loader
        android
        log
        dl
)
