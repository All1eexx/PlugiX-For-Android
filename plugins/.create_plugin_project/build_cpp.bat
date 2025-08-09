@echo off
setlocal enabledelayedexpansion

set "PROJECT_NAME=%~1"
if "%PROJECT_NAME%"=="" (
    echo ERROR: Project name is missing.
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
pushd "%SCRIPT_DIR%\.."
set "PLUGIN_ROOT=%CD%"
popd

set "CONFIG_FILE=%PLUGIN_ROOT%\config.ini"
set "TEMPLATE_DIR=%SCRIPT_DIR%\templates\cpp"
set "TARGET_DIR=%PLUGIN_ROOT%\%PROJECT_NAME%"

if not exist "%CONFIG_FILE%" (
    echo ERROR: Config file not found: %CONFIG_FILE%
    exit /b 1
)

for /f "usebackq tokens=1* delims==" %%A in (`findstr /b /r /c:"cmake=" /c:"ninja=" /c:"android_ndk=" /c:"default_abi=" /c:"min_sdk=" "%CONFIG_FILE%"`) do (
    set "key=%%A"
    set "val=%%B"
    set "!key!=!val!"
)

if "%cmake:~-1%"=="\" set "cmake=%cmake:~0,-1%"

for %%A in ("%cmake%") do set "cmake_dir=%%~dpA"

set "cmake_dir=%cmake_dir:bin\=%"

for %%B in ("%cmake_dir:~0,-1%") do (
    set "cmake_version=%%~nxB"
)

echo Using configuration:
echo cmake=%cmake%
echo ninja=%ninja%
echo android_ndk=%android_ndk%
echo default_abi=%default_abi%
echo min_sdk=%min_sdk%
echo cmake_version=%cmake_version%
echo.

if exist "%TARGET_DIR%" (
    echo WARNING: Target directory "%TARGET_DIR%" already exists.
) else (
    mkdir "%TARGET_DIR%"
)

if not exist "%TEMPLATE_DIR%" (
    echo ERROR: Template directory not found: %TEMPLATE_DIR%
    exit /b 1
)

xcopy /e /i /y "%TEMPLATE_DIR%\*" "%TARGET_DIR%\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy template files.
    exit /b 1
)

pushd "%TARGET_DIR%"

for %%F in (build_PLUGINNAME.bat PLUGINNAME.cpp PLUGINNAME.hpp) do (
    if exist "%%F" (
        set "oldname=%%F"
        set "newname=!oldname:PLUGINNAME=%PROJECT_NAME%!"
        ren "%%F" "!newname!"
    )
)

for %%F in (build_%PROJECT_NAME%.bat %PROJECT_NAME%.cpp %PROJECT_NAME%.hpp CMakeLists.txt) do (
    if exist "%%F" (
        call :ReplaceStringInFile "%%F" "PLUGINNAME" "%PROJECT_NAME%"
        call :ReplaceStringInFile "%%F" "{{CMAKEVERSION}}" "%cmake_version%"
        call :ReplaceStringInFile "%%F" "{{android_ndk}}" "%android_ndk%"
        call :ReplaceStringInFile "%%F" "{{default_abi}}" "%default_abi%"
        call :ReplaceStringInFile "%%F" "{{min_sdk}}" "%min_sdk%"
        call :ReplaceStringInFile "%%F" "{{cmake}}" "%cmake%"
        call :ReplaceStringInFile "%%F" "{{ninja}}" "%ninja%"
    )
)

popd

echo Project "%PROJECT_NAME%" created at "%TARGET_DIR%"
exit /b 0

:ReplaceStringInFile
setlocal enabledelayedexpansion
set "file=%~1"
set "search=%~2"
set "replace=%~3"
set "tempfile=%file%.tmp"

> "%tempfile%" (
    for /f "usebackq delims=" %%L in (%file%) do (
        set "line=%%L"
        setlocal enabledelayedexpansion
        set "line=!line:%search%=%replace%!"
        echo(!line!
        endlocal
    )
)

move /y "%tempfile%" "%file%" >nul
endlocal
goto :eof
