@echo off

:: Verify flutter install
flutter --version >nul 2>nul
if %errorlevel% neq 0 (
    echo Flutter não encontrado, instale o Flutter
    exit /b 1
)

:: Verify python virtual enviroment
if exist ".venv" (
    echo Ativando o ambiente virtual...
    call .venv\Scripts\activate.bat
) else (
    echo Ambiente virtual não encontrado, criando ambiente...
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
