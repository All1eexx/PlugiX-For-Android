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
if "!Plugin_type!"=="" goto SelectPluginType
if "!Plugin_type!"=="0" exit /b
if "!Plugin_type!"=="1" set "LANG_CODE=CC++" & set "Project_type=C/C++" & goto SelectProjectName
if "!Plugin_type!"=="2" set "LANG_CODE=java" & set "Project_type=Java" & goto SelectProjectName
if "!Plugin_type!"=="3" set "LANG_CODE=kotlin" & set "Project_type=Kotlin" & goto SelectProjectName
if "!Plugin_type!"=="4" set "LANG_CODE=rust" & set "Project_type=Rust" & goto SelectProjectName
echo ERROR: Invalid option! Choose 0-4.
goto SelectPluginType

:SelectProjectName
set /p "Project_name=   Write Project Name: "
if "!Project_name!"=="" goto SelectProjectName

echo.
echo Project type: !Project_type!
echo Project name: !Project_name!

if /I "!LANG_CODE!"=="java" goto JavaPackage
if /I "!LANG_CODE!"=="kotlin" goto JavaPackage
set "PACKAGE_NAME="
goto GetDest

:JavaPackage
echo.
:GetPackage
set "PACKAGE_NAME="
set /p "PACKAGE_NAME=   Enter package name (e.g. com.example): "
if "!PACKAGE_NAME!"=="" goto GetPackage

set "PACKAGE_NAME=!PACKAGE_NAME:"=!"
for /f "tokens=* delims= " %%A in ("!PACKAGE_NAME!") do set "PACKAGE_NAME=%%A"

if "!PACKAGE_NAME!"=="" goto GetPackage
if not "!PACKAGE_NAME: =!"=="!PACKAGE_NAME!" goto GetPackage
if "!PACKAGE_NAME!"=="!PACKAGE_NAME:.=!" goto GetPackage

echo Package accepted: !PACKAGE_NAME!
echo.
goto GetDest

:GetDest
echo Enter full absolute destination path where the project should be created.
set /p "CustomPath=   Destination path (absolute): "
if "!CustomPath!"=="" goto GetDest

set "CustomPath=!CustomPath:"=!"
if "!CustomPath:~-1!"=="\" set "CustomPath=!CustomPath:~0,-1!"

if exist "!CustomPath!\" (
    set "DEST=!CustomPath!\!Project_name!"
) else (
    set "DEST=!CustomPath!"
)

set "TestPath=!DEST!"
if not "!TestPath:~1,1!"==":" goto GetDest

set "SCRIPT_DIR=%~dp0"
if "!SCRIPT_DIR:~-1!"=="\" set "SCRIPT_DIR=!SCRIPT_DIR:~0,-1!"
set "BUILD_PLUGIN_BAT=!SCRIPT_DIR!\.create_plugin_project\build_plugin.bat"

if not exist "!BUILD_PLUGIN_BAT!" (
    echo ERROR: build_plugin.bat not found
    pause
    exit /b 1
)

echo.
echo Creating !Project_type! project "!Project_name!" at: !DEST!
echo.

if not defined PACKAGE_NAME set "PACKAGE_NAME="
call "!BUILD_PLUGIN_BAT!" "!LANG_CODE!" "!Project_name!" "!DEST!" "!PACKAGE_NAME!"

if !errorlevel! neq 0 (
    echo ERROR: Project creation failed
    pause
)

exit /b