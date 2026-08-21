@echo off
setlocal enabledelayedexpansion
title Pala Pack Installer for The Choicer Voicer

set "REPO=Palawizard/ChoicerVoicerPalaPack"
set "GAME=%APPDATA%\YeahMaybe\ChoicerVoicer\game"
set "HERE=%~dp0"
set "TMP=%TEMP%\ChoicerVoicerPalaPack"

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
curl -L --fail --progress-bar -o "%TMP%\pack.zip" "https://github.com/%REPO%/releases/latest/download/ChoicerVoicerPalaPack.zip"
if errorlevel 1 (
    echo.
    echo   Download failed. Check your internet connection and try again.
    pause
    exit /b 1
)

echo.
echo   Extracting...
tar -xf "%TMP%\pack.zip" -C "%TMP%"
if errorlevel 1 (
    echo.
    echo   Extraction failed.
    pause
    exit /b 1
)

if "%MODE%"=="2" (
    for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value') do set "DT=%%i"
    set "STAMP=!DT:~0,8!-!DT:~8,6!"
    set "BACKUP=%HERE%PalaPack Backup !STAMP!"
    echo.
    echo   Backing up your packs to:
    echo   !BACKUP!
    mkdir "!BACKUP!" || (echo   Cannot create backup folder. & pause & exit /b 1)
    for /d %%d in ("%GAME%\packs_*") do (
        robocopy "%%~fd" "!BACKUP!\%%~nxd" /e /njh /njs /ndl /nc /ns /nfl >nul
        if !errorlevel! geq 8 (echo   Backup of %%~nxd failed. & pause & exit /b 1)
    )
    echo   Removing your packs...
    for /d %%d in ("%GAME%\packs_*") do rmdir /s /q "%%~fd"
)

echo.
echo   Installing...
for /d %%d in ("%TMP%\packs_*") do (
    robocopy "%%~fd" "%GAME%\%%~nxd" /e /njh /njs /ndl /nc /ns /nfl >nul
    if !errorlevel! geq 8 (echo   Install of %%~nxd failed. & pause & exit /b 1)
)

rmdir /s /q "%TMP%"

echo.
echo   Done. Pala's packs are installed in:
echo   %GAME%
if "%MODE%"=="2" echo   Your old packs were backed up to: !BACKUP!
echo.
pause
