#!/bin/bash

# Validação básica de argumentos
if [ "$#" -ne 3 ]; then
    echo "Uso: $0 <SECRET_ID> <STACK_NAME> <TEMPLATE_FILE>"
    exit 1
fi

# Atribuição dos argumentos para variáveis
SECRET_ID=$1
STACK_NAME=$2
TEMPLATE_FILE=$3

# Obtém o ARN do secret
SECRET_ARN=$(aws secretsmanager describe-secret --secret-id $SECRET_ID --query 'ARN' --output text)
TOKEN=$(aws secretsmanager get-secret-value --secret-id \
    $SECRET_ARN --query 'SecretString' --output text)

# echo "Token1: $TOKEN"
TOKEN=$(aws secretsmanager get-secret-value --secret-id \
    $SECRET_ARN --query 'SecretString' --output text)
echo "TOKEN: $TOKEN"

GITHUB_TOKEN=$(echo $TOKEN | jq -r '.github_token')
echo "GitHub Token: $GITHUB_TOKEN"



# Verifica se obteu o ARN
if [ -z "$SECRET_ARN" ]; then
    echo "Erro ao obter o ARN do secret"
    exit 1
fi
# echo "Secret ARN: $SECRET_ARN"
# echo "Stack Name: $STACK_NAME"

# Cria ou atualiza a stack
# if aws cloudformation deploy \
#     --template-file $TEMPLATE_FILE \
#     --stack-name $STACK_NAME \
#     --parameter-overrides SecretsManagerArn=$SECRET_ARN StackName=$STACK_NAME \
#     --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
# then
#     echo "Stack $STACK_NAME atualizada ou criada com sucesso."
# else
#     echo "Falha ao atualizar ou criar a stack."
#     exit 1
# fi
