@echo off
setlocal enabledelayedexpansion

set PLUGIN_NAME=KotlinCoroutines_plugin
set ANDROID_SDK=D:\android-sdk
set BUILD_TOOLS_VERSION=36.0.0
set PLATFORM_VERSION=android-36
set JAVA_HOME=C:\Users\sasha\.jdks\temurin-24.0.1

set KOTLINC=C:\PROGRA~1\kotlinc\bin\kotlinc.bat
set D8=%ANDROID_SDK%\build-tools\%BUILD_TOOLS_VERSION%\d8.bat
set JAR="%JAVA_HOME%\bin\jar.exe"

set ANDROID_JAR=%ANDROID_SDK%\platforms\%PLATFORM_VERSION%\android.jar
set KOTLIN_STDLIB=C:\PROGRA~1\kotlinc\lib\kotlin-stdlib.jar
set KOTLIN_STDLIB_JDK8=C:\PROGRA~1\kotlinc\lib\kotlin-stdlib-jdk8.jar

set PROJECT_DIR=%~dp0
set SRC_FILE=%PROJECT_DIR%%PLUGIN_NAME%.kt
set OUTPUT_DIR=%PROJECT_DIR%build
set FINAL_DEX=%OUTPUT_DIR%\%PLUGIN_NAME%.dex
set COROUTINES_JAR=%PROJECT_DIR%kotlinx-coroutines-core-jvm-1.10.2.jar

echo Cleaning build folder...
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
mkdir "%OUTPUT_DIR%"

echo [1/4] Compiling Kotlin to .class files...
call "%KOTLINC%" "%SRC_FILE%" ^
    -classpath "%ANDROID_JAR%;%KOTLIN_STDLIB%;%KOTLIN_STDLIB_JDK8%;%COROUTINES_JAR%" ^
    -d "%OUTPUT_DIR%"
if errorlevel 1 (
    echo [ERROR] Kotlin compilation failed!
    exit /b 1
)

echo [2/4] Creating JAR archive...
%JAR% cvf "%OUTPUT_DIR%\classes.jar" -C "%OUTPUT_DIR%" .
if errorlevel 1 (
    echo [ERROR] JAR creation failed!
    exit /b 1
)

echo [3/4] Converting JAR to DEX format...
call "%D8%" ^
    --release ^
    --min-api 21 ^
    --lib "%ANDROID_JAR%" ^
    --output "%OUTPUT_DIR%" ^
    "%OUTPUT_DIR%\classes.jar" ^
    "%COROUTINES_JAR%"
if errorlevel 1 (
    echo [ERROR] DEX conversion failed!
    exit /b 1
)

echo [4/4] Verifying output...
if exist "%OUTPUT_DIR%\classes.dex" (
    rename "%OUTPUT_DIR%\classes.dex" "%PLUGIN_NAME%.dex"
    echo Success: DEX file created successfully!
) else (
    echo [ERROR] classes.dex not found!
    exit /b 1
)

echo.
echo [SUCCESS] Plugin built successfully!
echo Output: %FINAL_DEX%
for %%F in ("%FINAL_DEX%") do echo File size: %%~zF bytes

endlocal
exit /b 0