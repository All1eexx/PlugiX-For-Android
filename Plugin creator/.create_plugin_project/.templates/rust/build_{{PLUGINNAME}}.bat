@echo off
setlocal enabledelayedexpansion

set ANDROID_SDK_ROOT={{android_sdk}}
set ANDROID_NDK_HOME={{android_ndk}}
set "RUSTUP={{rustup}}"
set "CARGO_NDK={{cargo_ndk}}"
set PROJECT_DIR=%~dp0
set OUTPUT_DIR=%PROJECT_DIR%\jniLibs
set TARGET_ARCH={{default_abi}}
set ANDROID_PLATFORM={{min_sdk}}
set BUILD_TOOLS_VERSION={{build_tools_version}}

echo ========================================
echo Rust Android Build Script
echo ========================================

echo Checking environment...
if not exist "%ANDROID_NDK_HOME%" (
    echo ERROR: Android NDK not found at: %ANDROID_NDK_HOME%
    exit /b 1
)

if not exist "%PROJECT_DIR%" (
    echo ERROR: Project directory not found at: %PROJECT_DIR%
    exit /b 1
)

echo Setting up paths...
set PATH=%ANDROID_NDK_HOME%;%ANDROID_SDK_ROOT%\build-tools\%BUILD_TOOLS_VERSION%;%PATH%
set PATH={{cargo_dir}};{{rustc_dir}};%PATH%

cd /d "%PROJECT_DIR%"

echo Checking Rust target %TARGET_ARCH%-linux-android...
"%RUSTUP%" target list | find "%TARGET_ARCH%-linux-android" > nul
if %ERRORLEVEL% neq 0 (
    echo Adding Rust target...
    rustup target add %TARGET_ARCH%-linux-android
) else (
    echo Target already installed.
)

if exist "%OUTPUT_DIR%\%TARGET_ARCH%" (
    echo Cleaning previous build output...
    rmdir /s /q "%OUTPUT_DIR%\%TARGET_ARCH%"
)


echo Building Rust library for Android...

if not exist "%CARGO_NDK%" (
    echo ERROR: cargo-ndk not found at "%CARGO_NDK%"
    exit /b 1
)


"%CARGO_NDK%" ^
    --platform %ANDROID_PLATFORM% ^
    -t %TARGET_ARCH% ^
    -o "%OUTPUT_DIR%" ^
    build --release

set LIB_PATH=%OUTPUT_DIR%\%TARGET_ARCH%\libPLUGINNAME.so
if exist "%LIB_PATH%" (
    echo.
    echo SUCCESS: Library built successfully!
    echo Location: %LIB_PATH%
    echo Size: 
    for %%F in ("%LIB_PATH%") do echo %%~zF bytes
    echo.
    dir "%OUTPUT_DIR%\%TARGET_ARCH%"
    exit /b 0
) else (
    echo.
    echo ERROR: Build failed - output not found at: %LIB_PATH%
    echo Check build errors above.
)

echo.
echo Build process completed.
pause
