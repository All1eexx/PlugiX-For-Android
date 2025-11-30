@echo off
setlocal EnableDelayedExpansion

echo Building plugin

if not exist "gradlew.bat" (
    echo Error: gradlew.bat not found!
    pause
    exit /b 1
)

echo.
echo [1/5] Checking environment...
call gradlew checkEnvironment
if !errorlevel! neq 0 goto error

echo.
echo [2/5] Cleaning previous builds...
call gradlew clean
if !errorlevel! neq 0 goto error

echo.
echo [3/5] Building JAR and DEX files...
call gradlew buildAll
if !errorlevel! neq 0 goto error

echo.
echo [4/5] Checking output...
if not exist "output" (
    echo Output directory not created
    goto error
)

echo.
echo [5/5] Final result:
dir "output"

echo.
echo BUILD SUCCESSFUL!
echo Files created in output folder:
echo - %PLUGIN_NAME%.jar
echo - %PLUGIN_NAME%.dex
exit /b 0

:error
echo.
echo BUILD FAILED!
echo.
pause
exit /b 1

:end
pause

