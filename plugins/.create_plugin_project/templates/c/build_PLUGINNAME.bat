@echo off
echo Create directory Build
cd /d %~dp0
if exist build (
    echo Build directory already exists.
    cd build
) else (
    mkdir build
    cd build
    echo Build directory created.
)

"{{cmake}}" -G "Ninja" .. ^
  -DCMAKE_TOOLCHAIN_FILE={{android_ndk}}\build\cmake\android.toolchain.cmake ^
  -DANDROID_ABI={{default_abi}} ^
  -DANDROID_PLATFORM=android-{{min_sdk}} ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_MAKE_PROGRAM={{ninja}}

"{{cmake}}" --build .
