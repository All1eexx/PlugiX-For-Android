@echo off
setlocal enabledelayedexpansion
cls
color 0A

echo ##########################################
echo #            PlugiX Creator              #
echo ##########################################
echo #                                        #
echo #     1. C/C++ Plugin (.so)              #
echo #     2. Java Plugin (.dex)              #
echo #     3. Kotlin Plugin (.dex)            #
echo #     4. Rust Plugin (.so)               #
echo #     0. Exit                            #
echo #                                        #
echo ##########################################
echo.

:SelectPluginType
set /p "Plugin_type=   Select an option [0-4]: "

if "!Plugin_type!"=="" (
    echo ERROR: No input detected! Please try again.
    goto SelectPluginType
)

if "!Plugin_type!"=="0" (
    echo Exiting...
    exit /b
)

if "!Plugin_type!"=="1" set "LANG_CODE=CC++" & set "Project_type=C/C++" & goto SelectProjectName
if "!Plugin_type!"=="2" set "LANG_CODE=java" & set "Project_type=Java" & goto SelectProjectName
if "!Plugin_type!"=="3" set "LANG_CODE=kotlin" & set "Project_type=Kotlin" & goto SelectProjectName
if "!Plugin_type!"=="4" set "LANG_CODE=rust" & set "Project_type=Rust" & goto SelectProjectName

echo ERROR: Invalid option! Choose 0-4.
goto SelectPluginType

:SelectProjectName
set /p "Project_name=   Write Project Name: "

if "!Project_name!"=="" (
    echo ERROR: Project name cannot be empty! Please try again.
    goto SelectProjectName
)

echo.
echo Project type: !Project_type!
echo Project name: !Project_name!
echo.

:GetDest
echo Enter full absolute destination path where the project should be created.
echo You can specify an existing folder (project folder will be appended) or full path including project folder.
set /p "CustomPath=   Destination path (absolute): "

if "!CustomPath!"=="" (
    echo ERROR: Destination path cannot be empty. Please try again.
    goto GetDest
)

set "CustomPath=!CustomPath:"=!"

if "!CustomPath:~-1!"=="\" (
    if not "!CustomPath!"=="C:\" if not "!CustomPath!"=="D:\" if not "!CustomPath!"=="E:\" if not "!CustomPath!"=="F:\" (
        set "CustomPath=!CustomPath:~0,-1!"
    )
)

if exist "!CustomPath!\" (
    set "DEST=!CustomPath!\!Project_name!"
) else (
    set "DEST=!CustomPath!"
)

set "TestPath=!DEST!"
if "!TestPath:~0,1!"=="\" if "!TestPath:~1,1!"=="\" (
    goto PathValid
)
if "!TestPath:~1,1!"==":" (
    goto PathValid
)

echo ERROR: Path must be absolute (start with drive letter like C:\ or \\server\share). Please try again.
goto GetDest

:PathValid
set "SCRIPT_DIR=%~dp0"
if "!SCRIPT_DIR:~-1!"=="\" set "SCRIPT_DIR=!SCRIPT_DIR:~0,-1!"
set "BUILD_PLUGIN_BAT=!SCRIPT_DIR!\.create_plugin_project\build_plugin.bat"

if not exist "!BUILD_PLUGIN_BAT!" (
    echo ERROR: build_plugin.bat not found: !BUILD_PLUGIN_BAT!
    pause
    exit /b 1
)

echo.
echo Creating !Project_type! project "!Project_name!" at:
echo "!DEST!"
echo.

echo Running build_plugin.bat for !Project_type!...
call "!BUILD_PLUGIN_BAT!" "!LANG_CODE!" "!Project_name!" "!DEST!"

if !errorlevel! neq 0 (
    echo ERROR: Project creation failed with error code !errorlevel!
    pause
)

exit /b !errorlevel!