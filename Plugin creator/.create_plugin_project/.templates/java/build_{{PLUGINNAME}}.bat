@echo off

set PLUGIN_NAME=PLUGINNAME

set ANDROID_SDK={{android_sdk}}
set BUILD_TOOLS_VERSION={{build_tools_version}}
set PLATFORM_VERSION={{platform_version}}
set JAVA_HOME={{java_home}}

set PROJECT_DIR=%~dp0
set SRC_FILE=%PROJECT_DIR%%PLUGIN_NAME%.java
set OUTPUT_DIR=%PROJECT_DIR%build
set FINAL_DEX=%OUTPUT_DIR%\%PLUGIN_NAME%.dex

echo Cleaning build folder...
if exist "%OUTPUT_DIR%" (
    rmdir /s /q "%OUTPUT_DIR%"
)
mkdir "%OUTPUT_DIR%"

echo.
echo [1/3] Compiling Java to .class files...
"%JAVA_HOME%\bin\javac" --release 8 -classpath "%ANDROID_SDK%\platforms\%PLATFORM_VERSION%\android.jar" -d "%OUTPUT_DIR%" "%SRC_FILE%"
if errorlevel 1 (
    echo [ERROR] Java compilation failed!
    exit /b 1
)

echo.
echo [2/3] Creating JAR archive...
"%JAVA_HOME%\bin\jar" cvf "%OUTPUT_DIR%\classes.jar" -C "%OUTPUT_DIR%" .
if errorlevel 1 (
    echo [ERROR] JAR creation failed!
    exit /b 1
)

echo.
echo [3/3] Converting JAR to DEX format...
call "%ANDROID_SDK%\build-tools\%BUILD_TOOLS_VERSION%\d8" --release --output "%OUTPUT_DIR%" "%OUTPUT_DIR%\classes.jar"
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
echo [SUCCESS] Plugin built successfully!
echo Output: %FINAL_DEX%
for %%F in ("%FINAL_DEX%") do echo File size: %%~zF bytes

exit /b 0
