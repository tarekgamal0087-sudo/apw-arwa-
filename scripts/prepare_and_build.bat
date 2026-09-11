@echo off
setlocal
cd /d "%~dp0.."
echo [1/4] Checking Flutter...
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter is not installed or not in PATH.
  echo Install Flutter, then run this file again.
  pause
  exit /b 1
)
echo [2/4] Getting packages...
call flutter pub get
if errorlevel 1 exit /b 1
echo [3/4] Building release APK...
call flutter build apk --release
if errorlevel 1 exit /b 1
echo [4/4] Done.
echo APK: build\app\outputs\flutter-apk\app-release.apk
pause
