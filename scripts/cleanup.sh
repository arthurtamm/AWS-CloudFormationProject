#!/bin/bash

# Nome do repositório e informações do bucket
BUCKET_NAME="arthur-pipeline-bucket"
SECRET_NAME="github-access-token"

# Check if repo name is provided
if [ -z "$1" ]
then
  echo "Please provide the repository name as a parameter."
  exit 1
fi

REPO_NAME=$1

echo "Limpando o bucket S3..."
aws s3 rm s3://$BUCKET_NAME --recursive

echo "Deletando a stack infra-stack..."
aws cloudformation delete-stack --stack-name infra-stack

echo "Deletando a stack pipeline-stack..."
aws cloudformation delete-stack --stack-name pipeline-stack

echo "Aguardando a stack infra-stack ser completamente deletada..."
aws cloudformation wait stack-delete-complete --stack-name infra-stack

echo "Aguardando a stack pipeline-stack ser completamente deletada..."
aws cloudformation wait stack-delete-complete --stack-name pipeline-stack

# echo "Deletando o bucket S3..."
# aws s3api delete-bucket --bucket $BUCKET_NAME --region us-east-1

# Obtém e verifica a identidade do Git
GIT_USERNAME=$(gh api user --jq .login)
if [ -z "$GIT_USERNAME" ]; then
  echo "Falha ao recuperar o nome de usuário do GitHub. Verifique a configuração do GH CLI."
  exit 1
fi

echo "Todos os recursos foram limpos e deletados com sucesso."


