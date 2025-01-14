@echo off

:: Activate virtual environment
call .venv\Scripts\activate

:: Execute python script
python scripts\build.py windows

:: Desativa a virtual environment
deactivate

:: Navigate to app directory
cd /d %~dp0src\app\puremark

:: Execute flutter app
flutter run -d windows
