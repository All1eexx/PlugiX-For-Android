@echo off

set PLUGIN_NAME=KotlinToast_plugin

set ANDROID_SDK=D:\android-sdk
set BUILD_TOOLS_VERSION=36.0.0
set PLATFORM_VERSION=android-36
set KOTLIN_HOME=C:\Program Files\kotlinc
set JAVA_HOME=C:\Users\sasha\.jdks\temurin-24.0.1

set PROJECT_DIR=%~dp0
set SRC_FILE=%PROJECT_DIR%%PLUGIN_NAME%.kt
set OUTPUT_DIR=%PROJECT_DIR%build
set FINAL_DEX=%OUTPUT_DIR%\%PLUGIN_NAME%.dex

echo Cleaning build folder...
if exist "%OUTPUT_DIR%" (
    rmdir /s /q "%OUTPUT_DIR%"
)
mkdir "%OUTPUT_DIR%"

echo.
echo [1/3] Compiling Kotlin to .class files...
call "%KOTLIN_HOME%\bin\kotlinc.bat" "%SRC_FILE%" -classpath "%ANDROID_SDK%\platforms\%PLATFORM_VERSION%\android.jar;%KOTLIN_HOME%\lib\kotlin-stdlib.jar" -d "%OUTPUT_DIR%"
if errorlevel 1 (
    echo [ERROR] Kotlin compilation failed!
    exit /b 1
)

echo.
echo [2/3] Creating JAR archive...
"%JAVA_HOME%\bin\jar.exe" cvf "%OUTPUT_DIR%\classes.jar" -C "%OUTPUT_DIR%" .
if errorlevel 1 (
    echo [ERROR] JAR creation failed!
    exit /b 1
)

echo.
echo [3/3] Converting JAR to DEX format...
call "%ANDROID_SDK%\build-tools\%BUILD_TOOLS_VERSION%\d8.bat" --release --output "%OUTPUT_DIR%" "%OUTPUT_DIR%\classes.jar"
if errorlevel 1 (
    echo [ERROR] DEX conversion failed!
    exit /b 1
)

if exist "%OUTPUT_DIR%\classes.dex" (
    rename "%OUTPUT_DIR%\classes.dex" "%PLUGIN_NAME%.dex"
) else (
    echo [ERROR] classes.dex not found!
    exit /b 1
)

echo.
echo [SUCCESS] Kotlin plugin built successfully!
echo Output: %FINAL_DEX%
for %%F in ("%FINAL_DEX%") do echo File size: %%~zF bytes

exit /b 0
