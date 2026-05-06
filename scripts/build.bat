@echo off
set PLATFORM=%1
if "%PLATFORM%"=="" set PLATFORM=windows
set MODE=%2
if "%MODE%"=="" set MODE=debug
echo [build] platform=%PLATFORM% mode=%MODE%
REM TODO: add Godot export command
