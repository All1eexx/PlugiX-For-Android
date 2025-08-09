@echo off
cls
color 0A

echo ##########################################
echo #            PlugiX Creator              #
echo ##########################################
echo #                                        #
echo #     1. C++ Plugin (.so)                #
echo #     2. C Plugin (.so)                  #
echo #     3. Java Plugin (.dex)              #
echo #     4. Kotlin Plugin (.dex)            #
echo #     0. Exit                            #
echo #                                        #
echo ##########################################
echo.

:SelectPluginType
set /p "Plugin_type=   Select an option [0-4]: "

if "%Plugin_type%"=="" (
    echo ERROR: No input detected! Please try again.
    goto SelectPluginType
)

if "%Plugin_type%"=="1" (
    echo You selected: C++ Plugin "(.so)"
    set "Project_type=C++"
    goto SelectProjectName
) else if "%Plugin_type%"=="2" (
    echo You selected: C Plugin "(.so)"
    set "Project_type=C"
    goto SelectProjectName
) else if "%Plugin_type%"=="3" (
    echo You selected: Java Plugin "(.dex)"
    set "Project_type=Java"
    goto SelectProjectName
) else if "%Plugin_type%"=="4" (
    echo You selected: Kotlin Plugin "(.dex)"
    set "Project_type=Kotlin"
    goto SelectProjectName 
)else if "%Plugin_type%"=="0" (
    echo Exiting...
    exit /b
) else (
    echo ERROR: Invalid option! Choose 0-4.
    goto SelectPluginType
)

:SelectProjectName
set /p "Project_name=   Write Project Name: "

if "%Project_name%"=="" (
    echo ERROR: Project name cannot be empty! Please try again.
    goto SelectProjectName
)

echo.
echo Project type: %Project_type%
echo Project name: %Project_name%
echo.

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "BUILD_CPP_BAT=%SCRIPT_DIR%\.create_plugin_project\build_cpp.bat"
set "BUILD_C_BAT=%SCRIPT_DIR%\.create_plugin_project\build_c.bat"
set "BUILD_JAVA_BAT=%SCRIPT_DIR%\.create_plugin_project\build_java.bat"
set "BUILD_KOTLIN_BAT=%SCRIPT_DIR%\.create_plugin_project\build_kotlin.bat"

if "%Project_type%"=="C++" (
    if exist "%BUILD_CPP_BAT%" (
        echo Running build_cpp.bat with project name...
        call "%BUILD_CPP_BAT%" "%Project_name%"
    ) else (
        echo ERROR: build_cpp.bat not found in .create_plugin_project folder.
    )
) else if "%Project_type%"=="C" (
    if exist "%BUILD_C_BAT%" (
        echo Running build_c.bat with project name...
        call "%BUILD_C_BAT%" "%Project_name%"
    ) else (
        echo ERROR: build_c.bat not found in .create_plugin_project folder.
    )
)  else if "%Project_type%"=="Java" (
    if exist "%BUILD_JAVA_BAT%" (
        echo Running build_java.bat with project name...
        call "%BUILD_JAVA_BAT%" "%Project_name%"
    ) else (
        echo ERROR: build_java.bat not found in .create_plugin_project folder.
    )
) else if "%Project_type%"=="Kotlin" (
    if exist "%BUILD_KOTLIN_BAT%" (
        echo Running build_kotlin.bat with project name...
        call "%BUILD_KOTLIN_BAT%" "%Project_name%"
    ) else (
        echo ERROR: build_kotlin.bat not found in .create_plugin_project folder.
    )
) else (
    echo ERROR: Unknown project type.
)
