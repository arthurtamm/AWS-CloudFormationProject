#!/bin/bash

echo "Atualizando lista de pacotes..."
sudo apt update

# Instalação do AWS CLI
echo "Instalando AWS CLI..."
if ! command -v aws &> /dev/null; then
    sudo apt install unzip -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    if [ -f "awscliv2.zip" ]; then
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf awscliv2.zip aws/
        if command -v aws &> /dev/null; then
            echo "AWS CLI instalado com sucesso."
        else
            echo "Falha ao instalar AWS CLI."
            exit 1
        fi
    else
        echo "Falha ao baixar o AWS CLI."
        exit 1
    fi
else
    echo "AWS CLI já está instalado."
fi

# Instalação do GitHub CLI
echo "Instalando GitHub CLI..."
if ! command -v gh &> /dev/null; then
    sudo apt install gh -y
    if command -v gh &> /dev/null; then
        echo "GitHub CLI instalado com sucesso."
    else
        echo "Falha ao instalar GitHub CLI."
        exit 1
    fi
else
    echo "GitHub CLI já está instalado."
fi

# Instalação do Git
echo "Instalando Git..."
if ! command -v git &> /dev/null; then
    sudo apt install git -y
    if command -v git &> /dev/null; then
        echo "Git instalado com sucesso."
    else
        echo "Falha ao instalar Git."
        exit 1
    fi
else
    echo "Git já está instalado."
fi

# Instalação do JQ
echo "Instalando JQ..."
if ! command -v jq &> /dev/null; then
    sudo apt install jq -y
    if command -v jq &> /dev/null; then
        echo "JQ instalado com sucesso."
    else
        echo "Falha ao instalar JQ."
        exit 1
    fi
else
    echo "JQ já está instalado."
fi

# Instalação de xdg-utils para sistemas Linux
if [ "$(uname -o)" = "GNU/Linux" ]; then
    echo "Instalando xdg-utils para sistemas Linux..."
    if ! command -v xdg-open &> /dev/null; then
        sudo apt install xdg-utils -y
        if command -v xdg-open &> /dev/null; then
            echo "xdg-utils instalado com sucesso."
        else
            echo "Falha ao instalar xdg-utils."
            exit 1
        fi
    else
        echo "xdg-utils já está instalado."
    fi
fi

# Instalação de wslu para ambientes WSL
if grep -qi microsoft /proc/version; then
    echo "Detectado ambiente WSL, instalando wslu..."
    if ! command -v wslview &> /dev/null; then
        sudo apt install wslu -y
        if command -v wslview &> /dev/null; then
            echo "wslu instalado com sucesso."
        else
            echo "Falha ao instalar wslu."
            exit 1
        fi
    else
        echo "wslu já está instalado."
    fi
fi

# Instalação do Locust
echo "Instalando Locust..."
if ! command -v locust &> /dev/null; then
    sudo apt install python3-pip -y
    pip3 install locust
    if command -v locust &> /dev/null; then
        echo "Locust instalado com sucesso."
    else
        echo "Falha ao instalar Locust."
        exit 1
    fi
else
    echo "Locust já está instalado."
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

# Configuração interativa do GitHub CLI
# echo "Deseja fazer login no GitHub CLI agora? (sim/não)"
# read resposta
# if [[ "$resposta" == "sim" ]]; then
#   gh auth login
# else
#   echo "Você pode fazer login no GitHub CLI mais tarde executando 'gh auth login'."
# fi
