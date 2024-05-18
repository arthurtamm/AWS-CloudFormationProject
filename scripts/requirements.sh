#!/bin/bash

echo "Atualizando lista de pacotes..."
sudo apt update

echo "Instalando AWS CLI..."
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "Instalando GitHub CLI..."
sudo apt install gh -y

echo "Instalando Git..."
sudo apt install git -y

echo "Instalando JQ..."
sudo apt install jq -y

# Instalações específicas de sistema
if [ "$(uname -o)" = "GNU/Linux" ]; then
   echo "Instalando xdg-utils para sistemas Linux..."
   sudo apt install xdg-utils -y
fi

if grep -qi microsoft /proc/version; then
   echo "Detectado ambiente WSL, instalando wslu..."
   sudo apt install wslu -y
fi

echo "Instalações concluídas."

# Configuração interativa do AWS CLI
# echo "Deseja configurar o AWS CLI agora? (sim/não)"
# read resposta
# if [[ "$resposta" == "sim" ]]; then
#   aws configure
# else
#   echo "Você pode configurar o AWS CLI mais tarde executando 'aws configure'."
# fi

# # Configuração interativa do GitHub CLI
# echo "Deseja fazer login no GitHub CLI agora? (sim/não)"
# read resposta
# if [[ "$resposta" == "sim" ]]; then
#   gh auth login
# else
#   echo "Você pode fazer login no GitHub CLI mais tarde executando 'gh auth login'."
# fi
