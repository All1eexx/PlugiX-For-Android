@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo ERROR: No language type provided.
    echo Usage: %~nx0 {C/C++^|java/Kotlin^|rust} PluginName
    exit /b 1
)

if "%~2"=="" (
    echo ERROR: No plugin name provided.
    echo Usage: %~nx0 {C/C++^|java/Kotlin^|rust} PluginName [FullDestinationPath]
    exit /b 1
)

set "LANGUAGE=%~1"
set "PLUGIN_NAME=%~2"
set "CUSTOM_DEST=%~3"
set "PACKAGE_NAME=%~4"

if /i not "%LANGUAGE%"=="CC++" if /i not "%LANGUAGE%"=="javaKotlin" if /i not "%LANGUAGE%"=="rust" (
    echo ERROR: Invalid language. Supported: C/C++, java/Kotlin, rust
    exit /b 1
)

echo Creating %LANGUAGE% plugin project: %PLUGIN_NAME%

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

set "TEMPLATE_DIR=%SCRIPT_DIR%\.templates\%LANGUAGE%"

pushd "%SCRIPT_DIR%\.." >nul
set "TARGET_ROOT=%CD%"
popd >nul

if not "%CUSTOM_DEST%"=="" (
    set "DEST_DIR=%CUSTOM_DEST%"
) else (
    set "DEST_DIR=%TARGET_ROOT%\%PLUGIN_NAME%"
)

echo Template: "%TEMPLATE_DIR%"
echo Destination: "%DEST_DIR%"
echo Target Root: "%TARGET_ROOT%"
if not "%PACKAGE_NAME%"=="" echo Package: "%PACKAGE_NAME%"
echo.

if not exist "%TEMPLATE_DIR%" (
    echo ERROR: Template folder not found: "%TEMPLATE_DIR%"
    exit /b 1
)

if exist "%DEST_DIR%" (
    echo ERROR: Destination already exists: "%DEST_DIR%"
    exit /b 1
)

echo Copying template files...
mkdir "%DEST_DIR%"
powershell -NoProfile -Command "Copy-Item -Path '%TEMPLATE_DIR%\*' -Destination '%DEST_DIR%' -Recurse -Force"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to copy templates from "%TEMPLATE_DIR%" to "%DEST_DIR%"
    exit /b 1
)

echo Template copied successfully to: "%DEST_DIR%"
echo.

set "PS1=%TEMP%\plgx_replace_%RANDOM%.ps1"
del /f /q "%PS1%" >nul 2>&1

echo Param([string]$dst,[string]$name,[string]$targetRoot,[string]$packageName) > "%PS1%"
echo $cfgFile = Join-Path $targetRoot 'config.ini' >> "%PS1%"
echo $cfg = @{} >> "%PS1%"
echo if (Test-Path -Path $cfgFile) { >> "%PS1%"
echo     $section = '' >> "%PS1%"
echo     Get-Content -Path $cfgFile ^| ForEach-Object { >> "%PS1%"
echo         $line = $_.Trim() >> "%PS1%"
echo         if ($line -match '^^\[(.+)\]$') { $section = $matches[1].ToLower(); if (-not $cfg.ContainsKey($section)) { $cfg[$section] = @{} } } >> "%PS1%"
echo         elseif ($line -match '^^$' -or $line -match '^^[;#]') { } >> "%PS1%"
echo         else { >> "%PS1%"
echo             $parts = $line -split '=',2 >> "%PS1%"
echo             if ($parts.Length -eq 2) { >> "%PS1%"
echo                 $k = $parts[0].Trim() >> "%PS1%"
echo                 $v = $parts[1].Trim() >> "%PS1%"
echo                 if ($section -eq '') { $section = 'global' } >> "%PS1%"
echo                 if (-not $cfg.ContainsKey($section)) { $cfg[$section] = @{} } >> "%PS1%"
echo                 $cfg[$section][$k] = $v >> "%PS1%"
echo             } >> "%PS1%"
echo         } >> "%PS1%"
echo     } >> "%PS1%"
echo } >> "%PS1%"

echo function ResolveVal($val) { >> "%PS1%"
echo     if ($null -eq $val) { return $null } >> "%PS1%"
echo     $out = $val >> "%PS1%"
echo     $pattern = '\$\{(.+?):(.+?)\}' >> "%PS1%"
echo     while ($out -match $pattern) { >> "%PS1%"
echo         $sec = $matches[1].ToLower(); $key = $matches[2]; $rep = '' >> "%PS1%"
echo         if ($cfg.ContainsKey($sec) -and $cfg[$sec].ContainsKey($key)) { $rep = $cfg[$sec][$key] } >> "%PS1%"
echo         $out = $out -replace [regex]::Escape($matches[0]), $rep >> "%PS1%"
echo     } >> "%PS1%"
echo     $out = [Environment]::ExpandEnvironmentVariables($out) >> "%PS1%"
echo     return $out >> "%PS1%"
echo } >> "%PS1%"

echo $map = @{} >> "%PS1%"
echo $map['{{PLUGINNAME}}'] = $name >> "%PS1%"
echo if ($packageName -ne '') { $map['{{PACKAGENAME}}'] = $packageName } >> "%PS1%"

echo foreach ($sec in $cfg.Keys) { >> "%PS1%"
echo     foreach ($k in $cfg[$sec].Keys) { >> "%PS1%"
echo         $val = ResolveVal($cfg[$sec][$k]) >> "%PS1%"
echo         if ($val -ne $null -and $val -ne '') { >> "%PS1%"
echo             $map['{{' + $k + '}}'] = $val >> "%PS1%"
echo             $map['{{' + $k.ToUpper() + '}}'] = $val >> "%PS1%"
echo             $map['{{' + ($k -replace '_','') + '}}'] = $val >> "%PS1%"
echo             $map['{{' + ($k.ToUpper() -replace '_','') + '}}'] = $val >> "%PS1%"
echo             $map['{{' + ($k.Replace('_','').ToUpper()) + '}}'] = $val >> "%PS1%"
echo         } >> "%PS1%"
echo     } >> "%PS1%"
echo } >> "%PS1%"

echo # Map config values to template placeholders >> "%PS1%"
echo if ($cfg['android'] -and $cfg['android']['cmake']) { >> "%PS1%"
echo     $cmakeVal = ResolveVal($cfg['android']['cmake']) >> "%PS1%"
echo     $map['{{CMAKE}}'] = $cmakeVal >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['defaults'] -and $cfg['defaults']['cmake_version']) { >> "%PS1%"
echo     $map['{{CMAKE_VERSION}}'] = $cfg['defaults']['cmake_version'] >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['defaults'] -and $cfg['defaults']['default_abi']) { >> "%PS1%"
echo     $map['{{DEFAULT_ABI}}'] = $cfg['defaults']['default_abi'] >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['defaults'] -and $cfg['defaults']['min_sdk']) { >> "%PS1%"
echo     $map['{{MIN_SDK}}'] = $cfg['defaults']['min_sdk'] >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['defaults'] -and $cfg['defaults']['platform_version']) { >> "%PS1%"
echo     $map['{{COMPILE_SDK}}'] = $cfg['defaults']['platform_version'] >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['defaults'] -and $cfg['defaults']['java_version']) { >> "%PS1%"
echo     $javaVersion = $cfg['defaults']['java_version'] >> "%PS1%"
echo     # Extract only the first number (major version) >> "%PS1%"
echo     if ($javaVersion -match '^\d+') { >> "%PS1%"
echo         $map['{{JAVA_VERSION}}'] = $matches[0] >> "%PS1%"
echo     } else { >> "%PS1%"
echo         $map['{{JAVA_VERSION}}'] = $javaVersion >> "%PS1%"
echo     } >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['defaults'] -and $cfg['defaults']['kotlin_version']) { >> "%PS1%"
echo     $map['{{KOTLIN_VERSION}}'] = $cfg['defaults']['kotlin_version'] >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['android'] -and $cfg['android']['ndk']) { >> "%PS1%"
echo     $ndkVal = ResolveVal($cfg['android']['ndk']) >> "%PS1%"
echo     $map['{{ANDROID_NDK}}'] = $ndkVal >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['android'] -and $cfg['android']['sdk']) { >> "%PS1%"
echo     $ndkVal = ResolveVal($cfg['android']['sdk']) >> "%PS1%"
echo     $map['{{ANDROID_SDK}}'] = $ndkVal >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['kotlin'] -and $cfg['kotlin']['kotlin_home']) { >> "%PS1%"
echo     $ndkVal = ResolveVal($cfg['kotlin']['kotlin_home']) >> "%PS1%"
echo     $map['{{KOTLIN_HOME}}'] = $ndkVal >> "%PS1%"
echo } >> "%PS1%"
echo if ($cfg['android'] -and $cfg['android']['ninja']) { >> "%PS1%"
echo     $ninjaVal = ResolveVal($cfg['android']['ninja']) >> "%PS1%"
echo     $map['{{NINJA}}'] = $ninjaVal >> "%PS1%"
echo } >> "%PS1%"

echo Get-ChildItem -Path $dst -Recurse -File ^| ForEach-Object { >> "%PS1%"
echo     try { $text = Get-Content -Path $_.FullName -Raw -ErrorAction Stop } catch { $text = $null } >> "%PS1%"
echo     if ($null -ne $text) { >> "%PS1%"
echo         $new = $text >> "%PS1%"
echo         foreach ($k in $map.Keys) { >> "%PS1%"
echo             if ($map[$k] -ne $null -and $map[$k] -ne '') { >> "%PS1%"
echo                 $new = $new -replace [regex]::Escape($k), $map[$k] >> "%PS1%"
echo             } >> "%PS1%"
echo         } >> "%PS1%"
echo         if ($new -ne $text) { Set-Content -Path $_.FullName -Value $new -Encoding UTF8 -Force } >> "%PS1%"
echo     } >> "%PS1%"
echo } >> "%PS1%"

echo Get-ChildItem -Path $dst -Recurse ^| Where-Object { $_.Name -match '\{\{.+\}\}' } ^| Sort-Object FullName -Descending ^| ForEach-Object { >> "%PS1%"
echo     $newName = $_.Name >> "%PS1%"
echo     foreach ($k in $map.Keys) { >> "%PS1%"
echo         if ($map[$k] -ne $null -and $map[$k] -ne '') { >> "%PS1%"
echo             $newName = $newName -replace [regex]::Escape($k), $map[$k] >> "%PS1%"
echo         } >> "%PS1%"
echo     } >> "%PS1%"
echo     if ($newName -ne $_.Name) { >> "%PS1%"
echo         Rename-Item -Path $_.FullName -NewName $newName -Force -ErrorAction Stop >> "%PS1%"
echo     } >> "%PS1%"
echo } >> "%PS1%"

echo # Create package folder structure and move main class file for Java/Kotlin >> "%PS1%"
echo if ($packageName -ne '') { >> "%PS1%"
echo     $packagePath = $packageName.Replace('.', '\') >> "%PS1%"
echo     $javaSrcDir = Join-Path $dst 'src\main\java' >> "%PS1%"
echo     $kotlinSrcDir = Join-Path $dst 'src\main\kotlin' >> "%PS1%"
echo     >> "%PS1%"
echo     # Check if Java source directory exists >> "%PS1%"
echo     if (Test-Path -Path $javaSrcDir) { >> "%PS1%"
echo         $mainClassFile = Join-Path $javaSrcDir ($name + '.java') >> "%PS1%"
echo         $targetPackageDir = Join-Path $javaSrcDir $packagePath >> "%PS1%"
echo         >> "%PS1%"
echo         if (Test-Path -Path $mainClassFile) { >> "%PS1%"
echo             if (-not (Test-Path -Path $targetPackageDir)) { >> "%PS1%"
echo                 New-Item -ItemType Directory -Path $targetPackageDir -Force ^| Out-Null >> "%PS1%"
echo             } >> "%PS1%"
echo             Move-Item -Path $mainClassFile -Destination $targetPackageDir -Force >> "%PS1%"
echo             Write-Host "Moved Java main class to: $targetPackageDir" >> "%PS1%"
echo         } >> "%PS1%"
echo     } >> "%PS1%"
echo     >> "%PS1%"
echo     # Check if Kotlin source directory exists >> "%PS1%"
echo     if (Test-Path -Path $kotlinSrcDir) { >> "%PS1%"
echo         $mainClassFile = Join-Path $kotlinSrcDir ($name + '.kt') >> "%PS1%"
echo         $targetPackageDir = Join-Path $kotlinSrcDir $packagePath >> "%PS1%"
echo         >> "%PS1%"
echo         if (Test-Path -Path $mainClassFile) { >> "%PS1%"
echo             if (-not (Test-Path -Path $targetPackageDir)) { >> "%PS1%"
echo                 New-Item -ItemType Directory -Path $targetPackageDir -Force ^| Out-Null >> "%PS1%"
echo             } >> "%PS1%"
echo             Move-Item -Path $mainClassFile -Destination $targetPackageDir -Force >> "%PS1%"
echo             Write-Host "Moved Kotlin main class to: $targetPackageDir" >> "%PS1%"
echo         } >> "%PS1%"
echo     } >> "%PS1%"
echo } >> "%PS1%"

echo Running placeholder replacement and package setup...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" "%DEST_DIR%" "%PLUGIN_NAME%" "%TARGET_ROOT%" "%PACKAGE_NAME%"
set "RC=%ERRORLEVEL%"

echo Cleaning up temporary files...
del /f /q "%DEST_DIR%\plgx_replace_debug.ps1" >nul 2>&1
del /f /q "%PS1%" >nul 2>&1

if %RC% NEQ 0 (
    echo WARNING: Some replacements or renames may have failed.
    exit /b %RC%
)

echo.
echo SUCCESS! Project created at: "%DEST_DIR%"
echo.

endlocal
exit /b 0