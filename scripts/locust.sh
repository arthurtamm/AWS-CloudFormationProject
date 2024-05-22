#!/bin/bash

# Nome do load balancer a ser buscado (prefixo)
LB_NAME_PREFIX="infra"

# Obtenha o nome do load balancer cujo nome começa com o prefixo fornecido
LOAD_BALANCER_NAME=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?starts_with(LoadBalancerName, '${LB_NAME_PREFIX}')].LoadBalancerName" --output text)

if [ -z "$LOAD_BALANCER_NAME" ]; then
  echo "Nenhum Load Balancer encontrado com o prefixo ${LB_NAME_PREFIX}"
  exit 1
fi

# Obtenha o DNS do load balancer encontrado
DNS_NAME=$(aws elbv2 describe-load-balancers --names "$LOAD_BALANCER_NAME" --query "LoadBalancers[0].DNSName" --output text)

if [ -z "$DNS_NAME" ]; then
  echo "Não foi possível obter o DNS do Load Balancer ${LOAD_BALANCER_NAME}"
  exit 1
fi

# Adiciona o diretório onde o Locust está instalado ao PATH (ajuste o caminho conforme necessário)
# export PATH=$PATH:/usr/local/bin

# Iniciar o Locust com a URL do DNS encontrado e com os parâmetros desejados
locust -f ./locustfile.py --host="http://${DNS_NAME}" -u 100 -r 1 -t 12m &

# Espera um pouco para garantir que o Locust inicie
sleep 5

# Abrir a interface web do Locust no navegador
xdg-open http://localhost:8089 || open http://localhost:8089 || start http://localhost:8089
