@echo off
verify on
title ROZTRIDIT_HOTOVE_SOUBORY.bat

REM  *_MUTE.*  *_UP512.*  *_UP1024.*  *_UP2048.*

:label_mute
dir *_MUTE.* > nul
if errorlevel 1 goto label_UP512
mkdir mute
echo BYL VYTVOREN NOVY ADRESAR "mute"
move /Y *_MUTE.* mute

:label_UP512
dir *_UP512.* > nul
if errorlevel 1 goto label_UP1024
mkdir 512
echo BYL VYTVOREN NOVY ADRESAR "512"
move /Y *_UP512.* 512

:label_UP1024
dir *_UP1024.* > nul
if errorlevel 1 goto label_UP2048
mkdir 1024
echo BYL VYTVOREN NOVY ADRESAR "1024"
move /Y *_UP1024.* 1024

:label_UP2048
dir *_UP2048.* > nul
if errorlevel 1 goto label_konec
mkdir 2048
echo BYL VYTVOREN NOVY ADRESAR "2048"
move /Y *_UP2048.* 2048

:label_konec
pause
