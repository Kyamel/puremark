#!/usr/bin/env bash

# Verificar se o Flutter está instalado
flutter --version || { echo "Flutter não encontrado, instale o Flutter"; exit 1; }

# Verificar e ativar o ambiente virtual
if [ -d ".venv" ]; then
  echo "Ativando o ambiente virtual..."
  source .venv/bin/activate
else
  echo "Ambiente virtual não encontrado, criando ambiente..."
  python3 -m venv .venv
  source .venv/bin/activate
fi

# Executar o script Python
echo "Executando o script Python para build..."
python3 scripts/build.py linux

# Navegar para o diretório do app Flutter
echo "Navegando para o diretório do app Flutter..."
cd ./src/app/puremark

# Executar o app Flutter para Linux
echo "Executando o Flutter para Linux..."
flutter run -d linux
