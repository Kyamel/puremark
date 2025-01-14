@echo off

:: Verify python virtual enviroment
if exist ".venv" (
    call .venv\Scripts\activate.bat
) else (
    echo Virtual enviroment not found, creating .venv...
    python -m venv .venv
    call .venv\Scripts\activate.bat
)

:: Execute python script
python scripts\build.py windows

:: Navigate to app directory
cd /d %~dp0src\app\puremark

:: Ensure flutter is available and run the app
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Flutter command not found. Please ensure Flutter is in your PATH.
    exit /b 1
)

:: Execute flutter app
flutter run -d windows