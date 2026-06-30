cmake_minimum_required(VERSION 3.22.1)

project(kepemilikan LANGUAGES C CXX ASM)

if(ANDROID_ABI STREQUAL "arm64-v8a")
    set(MAGIC_ASM magic_arm64.S)
elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
    set(MAGIC_ASM magic_armv7.S)
elseif(ANDROID_ABI STREQUAL "x86_64")
    set(MAGIC_ASM magic_x86_64.S)
else()
    set(MAGIC_ASM "")
endif()

add_library(kepemilikan SHARED kepemilikan.cpp ${MAGIC_ASM})

target_compile_options(kepemilikan PRIVATE -fvisibility=hidden -O2)
