@echo off
setlocal enabledelayedexpansion

set ANDROID_SDK_ROOT=D:\android-sdk
set ANDROID_NDK_HOME=%ANDROID_SDK_ROOT%\ndk\29.0.13846066
set PROJECT_DIR=D:\Projects\PlugiX For Android\plugins\RustToast_plugin
set OUTPUT_DIR=%PROJECT_DIR%\jniLibs
set TARGET_ARCH=x86_64
set ANDROID_PLATFORM=21

cls

echo ========================================
echo Rust Android Build Script
echo ========================================

echo Checking environment...
if not exist "%ANDROID_NDK_HOME%" (
    echo ERROR: Android NDK not found at: %ANDROID_NDK_HOME%
    pause
    exit /b 1
)

if not exist "%PROJECT_DIR%" (
    echo ERROR: Project directory not found at: %PROJECT_DIR%
    pause
    exit /b 1
)

echo Setting up paths...
set PATH=%ANDROID_NDK_HOME%;%ANDROID_SDK_ROOT%\build-tools\36.0.0;%PATH%
set PATH=C:\Users\sasha\.cargo\bin;C:\Users\sasha\.rustup\toolchains\stable-x86_64-pc-windows-msvc\bin;%PATH%

cd /d "%PROJECT_DIR%"

echo Checking Rust target %TARGET_ARCH%-linux-android...
rustup target list | find "%TARGET_ARCH%-linux-android" > nul
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
echo Target: %TARGET_ARCH%
echo Platform: android-%ANDROID_PLATFORM%
echo Output: %OUTPUT_DIR%

cargo ndk ^
    --platform %ANDROID_PLATFORM% ^
    -t %TARGET_ARCH% ^
    -o "%OUTPUT_DIR%" ^
    build --release

set LIB_PATH=%OUTPUT_DIR%\%TARGET_ARCH%\libRustToast_plugin.so
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