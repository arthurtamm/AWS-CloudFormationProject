#!/bin/bash

# Parâmetro esperado
SECRET_NAME="github-access-token"

PIPELINE_NAME="MyPipeline"

# Check if repo name is provided
if [ -z "$1" ]
then
  echo "Please provide the repository name as a parameter."
  exit 1
fi

REPO_NAME=$1

# Função para obter o estado da última execução do pipeline
get_latest_pipeline_execution_status() {
    aws codepipeline list-pipeline-executions --pipeline-name $PIPELINE_NAME --query 'pipelineExecutionSummaries[0].status' --output text
}

# Função para aguardar a conclusão do pipeline
wait_for_pipeline_completion() {
    echo "Waiting for the pipeline to complete..."
    while true; do
        STATUS=$(get_latest_pipeline_execution_status)
        
        case $STATUS in
            "Succeeded")
                echo "Pipeline execution completed successfully."
                break
                ;;
            "Failed")
                echo "Pipeline execution failed."
                exit 1
                ;;
            "Stopped")
                echo "Pipeline execution stopped manually."
                exit 1
                ;;
            "Stopping")
                echo "Pipeline is currently stopping..."
                ;;
            "Superseded")
                echo "Pipeline execution superseded by a newer execution."
                ;;
            *)
                echo "Pipeline is still running... Current status: $STATUS"
                sleep 60  # Espera por 60 segundos antes de verificar novamente
                ;;
        esac
    done
}

# Buscando o ARN do segredo no AWS Secrets Manager
SECRET_ARN=$(aws secretsmanager describe-secret --secret-id $SECRET_NAME --query 'ARN' --output text)
if [ -z "$SECRET_ARN" ]; then
  echo "Failed to retrieve ARN for secret $SECRET_NAME"
  exit 1
fi

# cd ..

echo "Deploying the pipeline stack..." 

# Verifica se o arquivo pipeline.yaml existe
if [ -f "pipeline.yaml" ]; then
  # Deployando a stack CloudFormation
  aws cloudformation deploy \
    --template-file pipeline.yaml \
    --stack-name pipeline-stack \
    --parameter-overrides SecretsManagerArn=$SECRET_ARN RepositoryName=$REPO_NAME \
    --capabilities CAPABILITY_NAMED_IAM || echo "Deployment failed. Please check the AWS console or run aws cloudformation describe-stack-events --stack-name pipeline-stack"
    
  echo "Waiting for pipeline-stack to complete..."
  aws cloudformation wait stack-create-complete --stack-name pipeline-stack
else
  echo "Invalid template path pipeline.yaml"
fi

wait_for_pipeline_completion
echo "Pipeline stack deployed successfully."

aws cloudformation wait stack-create-complete --stack-name infra-stack
echo "Infrastructure stack deployed successfully."

URL=$(aws cloudformation describe-stacks --stack-name infra-stack --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' --output text)
URL="http://${URL}"  # Adiciona o protocolo para formar um URL completo

# Tenta abrir o navegador dependendo do sistema operacional ou imprime o URL
case "$OSTYPE" in
  linux*|linux-gnu*)
    if [[ -n "$WSL_DISTRO_NAME" ]]; then
      # Estamos no WSL, tenta usar wslview
      wslview $URL
    elif command -v xdg-open > /dev/null; then
      xdg-open $URL
    else
      echo "No web browser found. Please open the following URL in your web browser: $URL"
    fi
    ;;
  darwin*)
    open $URL
    ;;
  cygwin*|mingw*|msys*|win32*)
    start $URL
    ;;
  *)
    echo "Please open the following URL in your web browser: $URL"
    ;;
esac

echo "Access in: http://$URL"