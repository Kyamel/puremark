@echo off

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
