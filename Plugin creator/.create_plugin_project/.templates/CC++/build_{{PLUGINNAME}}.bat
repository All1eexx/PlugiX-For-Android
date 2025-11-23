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
"{{CMAKE}}" -G "Ninja" ..

"{{CMAKE}}" --build .
