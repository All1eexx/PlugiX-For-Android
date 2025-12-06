@echo off
setlocal enabledelayedexpansion

set ANDROID_SDK_ROOT={{ANDROID_SDK}}
set ANDROID_NDK_HOME={{ANDROID_NDK}}
set "RUSTUP={{rustup}}"
set "CARGO_NDK={{cargo_ndk}}"
set PROJECT_DIR=%~dp0
set OUTPUT_DIR=%PROJECT_DIR%\jniLibs
set TARGET_ARCH={{default_abi}}
set ANDROID_PLATFORM={{min_sdk}}










echo ========================================
echo Rust Android Build Script
echo ========================================

echo Checking environment...

where cargo >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Cargo not found in PATH
    echo Please install Rust or add it to PATH
    pause
    exit /b 1
)

if not exist "%ANDROID_NDK_HOME%" (
    echo ERROR: Android NDK not found at: %ANDROID_NDK_HOME%
    echo Please set ANDROID_NDK_HOME environment variable
    pause
    exit /b 1
)

cd /d "%PROJECT_DIR%"

echo Extracting library name from Cargo.toml...

if exist "Cargo.toml" (
    for /f "tokens=*" %%a in ('type "Cargo.toml"') do (
        set "line=%%a"
        
        set "line=!line: =!"
        
        if "!line:~0,5!"=="name=" (
            set "CRATE_NAME=!line:~5!"
            
            set "CRATE_NAME=!CRATE_NAME:"=!"
            
            for /f "tokens=1 delims=#" %%c in ("!CRATE_NAME!") do (
                set "CRATE_NAME=%%c"
            )
            
            set "CRATE_NAME=!CRATE_NAME: =!"
            
            echo Found crate name: !CRATE_NAME!
            set LIB_NAME=lib!CRATE_NAME!.so
            goto :name_found
        )
    )
)

:name_found
echo Library will be named: !LIB_NAME!

echo Checking Rust target %TARGET_ARCH%-linux-android...
rustup target list | find "%TARGET_ARCH%-linux-android" > nul
if %ERRORLEVEL% neq 0 (
    echo Adding Rust target...
    rustup target add %TARGET_ARCH%-linux-android
) else (
    echo Target already installed.
)

echo Checking cargo-ndk...
cargo ndk --help >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo cargo-ndk not found, installing...
    cargo install cargo-ndk
)

if exist "%OUTPUT_DIR%\%TARGET_ARCH%" (
    echo Cleaning previous build output...
    rmdir /s /q "%OUTPUT_DIR%\%TARGET_ARCH%" 2>nul
)

echo.
echo Building Rust library for Android...

cargo ndk ^
    --platform %ANDROID_PLATFORM% ^
    --target %TARGET_ARCH% ^
    --output-dir "%OUTPUT_DIR%" ^
    build --release

set LIB_PATH=%OUTPUT_DIR%\%TARGET_ARCH%\!LIB_NAME!

if not exist "%LIB_PATH%" (
    echo.
    echo WARNING: Library not found at: %LIB_PATH%
    echo Searching for .so files...
    
    dir /b "%OUTPUT_DIR%\%TARGET_ARCH%\*.so" 2>nul
    if exist "%OUTPUT_DIR%\%TARGET_ARCH%\*.so" (
        echo Found .so files, using first one...
        for %%f in ("%OUTPUT_DIR%\%TARGET_ARCH%\*.so") do (
            set LIB_PATH=%%f
            goto :found
        )
    )
    
    echo ERROR: No .so files found
    echo Check if build succeeded
    pause
    exit /b 1
)

:found
echo.
echo SUCCESS: Library built!
echo Location: %LIB_PATH%
for %%F in ("%LIB_PATH%") do echo Size: %%~zF bytes

echo.
echo Build completed successfully!
pause