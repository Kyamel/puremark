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

:: Desctivates virtual enviroment
deactivate

:: Navigate to app directory
cd /d %~dp0src\app\puremark

:: Execute flutter app
flutter run -d windows
