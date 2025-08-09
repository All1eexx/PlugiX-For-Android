@echo off
setlocal enabledelayedexpansion

set "PROJECT_NAME=%~1"
if "%PROJECT_NAME%"=="" (
    echo ERROR: Project name is missing.
    exit /b 1
)

rem === Папки ===
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
pushd "%SCRIPT_DIR%\.."
set "PLUGIN_ROOT=%CD%"
popd

set "CONFIG_FILE=%PLUGIN_ROOT%\config.ini"
set "TEMPLATE_DIR=%SCRIPT_DIR%\templates\kotlin"
set "TARGET_DIR=%PLUGIN_ROOT%\%PROJECT_NAME%"

if not exist "%CONFIG_FILE%" (
    echo ERROR: Config file not found: %CONFIG_FILE%
    exit /b 1
)

rem === Читаем config.ini ===
for /f "usebackq tokens=1* delims==" %%A in (`
    findstr /b /r /c:"android_sdk=" /c:"java_home=" /c:"kotlin_home=" /c:"d8=" /c:"default_abi=" /c:"min_sdk=" /c:"build_tools_version=" /c:"platform_version=" "%CONFIG_FILE%"
`) do (
    set "key=%%A"
    set "val=%%B"
    set "!key!=!val!"
)

rem === Вывод для отладки ===
echo Using configuration:
echo android_sdk=%android_sdk%
echo java_home=%java_home%
echo kotlin_home=%kotlin_home%
echo d8=%d8%
echo build_tools_version=%build_tools_version%
echo platform_version=%platform_version%
echo default_abi=%default_abi%
echo min_sdk=%min_sdk%
echo.

rem === Создание проекта ===
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

rem === Переименовываем шаблонные файлы ===
for %%F in (build_PLUGINNAME.bat PLUGINNAME.kt) do (
    if exist "%%F" (
        set "oldname=%%F"
        set "newname=!oldname:PLUGINNAME=%PROJECT_NAME%!"
        ren "%%F" "!newname!"
    )
)

rem === Заменяем плейсхолдеры ===
for %%F in (build_%PROJECT_NAME%.bat %PROJECT_NAME%.kt) do (
    if exist "%%F" (
        call :ReplaceStringInFile "%%F" "PLUGINNAME" "%PROJECT_NAME%"
        call :ReplaceStringInFile "%%F" "{{android_sdk}}" "%android_sdk%"
        call :ReplaceStringInFile "%%F" "{{java_home}}" "%java_home%"
        call :ReplaceStringInFile "%%F" "{{kotlin_home}}" "%kotlin_home%"
        call :ReplaceStringInFile "%%F" "{{d8}}" "%d8%"
        call :ReplaceStringInFile "%%F" "{{build_tools_version}}" "%build_tools_version%"
        call :ReplaceStringInFile "%%F" "{{platform_version}}" "%platform_version%"
        call :ReplaceStringInFile "%%F" "{{default_abi}}" "%default_abi%"
        call :ReplaceStringInFile "%%F" "{{min_sdk}}" "%min_sdk%"
    )
)

popd

echo Kotlin project "%PROJECT_NAME%" created at "%TARGET_DIR%"
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
