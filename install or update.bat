@echo off
setlocal enabledelayedexpansion
title Pala Pack Installer for The Choicer Voicer

set "REPO=Palawizard/ChoicerVoicerPalaPack"
set "GAME=%APPDATA%\YeahMaybe\ChoicerVoicer\game"
set "HERE=%~dp0"
set "TMP=%TEMP%\ChoicerVoicerPalaPack"
set "CURL=%SystemRoot%\System32\curl.exe"
set "TAR=%SystemRoot%\System32\tar.exe"
set "RC=%SystemRoot%\System32\robocopy.exe"
set "SELF=%~f0"
set "RAW=https://raw.githubusercontent.com/%REPO%/main/install%%20or%%20update.bat"
set "NEW=%TEMP%\ChoicerVoicerPalaPack.new.bat"
set "UPD=%TEMP%\ChoicerVoicerPalaPack.update.cmd"
del /q "%UPD%" 2>nul

if /i not "%~1"=="updated" (
    echo.
    echo   Checking for installer updates...
    "%CURL%" -sL --fail -o "%NEW%" "%RAW%"
    if not errorlevel 1 (
        fc /b "%NEW%" "%SELF%" >nul 2>&1
        if errorlevel 1 goto :selfupdate
    )
    del /q "%NEW%" 2>nul
)

echo.
echo  ============================================
echo   Pala Pack - Install or Update
echo  ============================================
echo.
echo   Game folder: %GAME%
echo.
echo   [1] Install or Update
echo       Adds Pala's packs to your game. Your own packs are kept.
echo.
echo   [2] Install or Update - Exact Sync
echo       Backs up your voicepacks, dubs, etc. next to this file,
echo       then removes them and installs only Pala's packs.
echo       Use this for the multiplayer mod, which requires everyone
echo       to have exactly the same packs.
echo.
set "MODE="
set /p "MODE=  Enter 1 or 2: "
if "%MODE%"=="1" goto :start
if "%MODE%"=="2" goto :start
echo.
echo   Invalid choice.
pause
exit /b 1

:start
if not exist "%GAME%\" (
    echo.
    echo   Game folder not found. Run The Choicer Voicer at least once, then retry.
    pause
    exit /b 1
)

if exist "%TMP%\" rmdir /s /q "%TMP%"
mkdir "%TMP%" || (echo   Cannot write to %TEMP%. & pause & exit /b 1)

echo.
echo   Downloading latest pack (this is large, please wait)...
"%CURL%" -L --fail --progress-bar -o "%TMP%\pack.zip" "https://github.com/%REPO%/releases/latest/download/ChoicerVoicerPalaPack.zip"
if errorlevel 1 (
    echo.
    echo   Download failed. Check your internet connection and try again.
    pause
    exit /b 1
)

echo.
echo   Extracting...
"%TAR%" -xf "%TMP%\pack.zip" -C "%TMP%"
if errorlevel 1 (
    echo.
    echo   Extraction failed.
    pause
    exit /b 1
)

if "%MODE%"=="2" (
    for /f %%i in ('powershell -nop -c "Get-Date -f yyyyMMdd-HHmmss"') do set "STAMP=%%i"
    set "BACKUP=%HERE%PalaPack Backup !STAMP!"
    echo.
    echo   Backing up your packs to:
    echo   !BACKUP!
    mkdir "!BACKUP!" || (echo   Cannot create backup folder. & pause & exit /b 1)
    for /d %%d in ("%GAME%\packs_*") do (
        "%RC%" "%%~fd" "!BACKUP!\%%~nxd" /e /njh /njs /ndl /nc /ns /nfl >nul
        if !errorlevel! geq 8 (echo   Backup of %%~nxd failed. & pause & exit /b 1)
    )
    echo   Removing your packs...
    for /d %%d in ("%GAME%\packs_*") do rmdir /s /q "%%~fd"
)

echo.
echo   Installing...
for /d %%d in ("%TMP%\packs_*") do (
    "%RC%" "%%~fd" "%GAME%\%%~nxd" /e /njh /njs /ndl /nc /ns /nfl >nul
    if !errorlevel! geq 8 (echo   Install of %%~nxd failed. & pause & exit /b 1)
)

rmdir /s /q "%TMP%"

echo.
echo   Done. Pala's packs are installed in:
echo   %GAME%
if "%MODE%"=="2" echo   Your old packs were backed up to: !BACKUP!
echo.
pause
exit /b 0

:selfupdate
echo   A newer installer is available. Updating and restarting...
> "%UPD%" echo @echo off
>>"%UPD%" echo ping -n 2 127.0.0.1 ^>nul
>>"%UPD%" echo copy /y "%NEW%" "%SELF%" ^>nul
>>"%UPD%" echo del /q "%NEW%" ^>nul
>>"%UPD%" echo start "" "%SELF%" updated
start "" cmd /c "%UPD%"
exit
