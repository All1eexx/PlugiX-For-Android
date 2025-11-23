@echo off

echo Create directory Build

cd /d D:\Projects\DynamicNativePluginLoaderforAndroid\plugins\SendNotification_plugin

if exist build (
    echo Build directory already exists.
    cd build
) else (
    mkdir build
    cd build
    echo Build directory created.
)

"D:\android-sdk\cmake\4.0.3\bin\cmake.exe" -G "Ninja" .. ^
  -DCMAKE_TOOLCHAIN_FILE=D:/android-sdk/ndk/29.0.13846066/build/cmake/android.toolchain.cmake ^
  :: armeabi-v7a or arm64-v8a or x86 or x86_64 ^
  -DANDROID_ABI=x86_64 ^
  -DANDROID_PLATFORM=android-21 ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_MAKE_PROGRAM=D:/android-sdk/cmake/4.0.3/bin/ninja.exe

"D:\android-sdk\cmake\4.0.3\bin\cmake.exe" --build .