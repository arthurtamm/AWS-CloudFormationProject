#!/bin/bash

# Parâmetro esperado
SECRET_NAME="github-access-token"

# Obtém e verifica a identidade do Git
GIT_USERNAME=$(gh api user --jq .login)
GIT_EMAIL=$(gh api user/emails --jq '.[] | select(.primary==true) | .email')
PIPELINE_NAME="MyPipeline"

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

if [ -z "$GIT_USERNAME" ] || [ -z "$GIT_EMAIL" ]; then
  echo "Git user name and email are not set."
  echo "Run the following commands to set them:"
  echo "git config --global user.name \"Your Name\""
  echo "git config --global user.email \"you@example.com\""
  exit 1
fi

cd ..

# Criando o repositório no GitHub e clonando
REPO_NAME="CloudFormationProject-Pipeline"

# Verifica se o diretório do repositório já existe
if [ ! -d "$REPO_NAME" ]; then
  gh repo create $REPO_NAME --private --clone
  cd $REPO_NAME
else
  echo "Repositório já clonado."
  cd $REPO_NAME
  # Configura o branch upstream se não estiver configurado
  git remote add origin https://github.com/$GIT_USERNAME/$REPO_NAME.git
  git fetch --all
  git branch --set-upstream-to=origin/master master
  git pull origin master
fi

# Verifica se o project.yaml está no diretório atual ou um nível acima
if [ -f "../project.yaml" ]; then
  # Move o arquivo para o diretório atual se estiver um nível acima
  cp ../project.yaml .
fi

# Adicionando project.yaml se ele existir
if [ -f "project.yaml" ]; then
  git add project.yaml
  git commit -m "Add CloudFormation project.yaml."
  git push origin master
else
  echo "Arquivo project.yaml não encontrado."
fi

# Buscando o ARN do segredo no AWS Secrets Manager
SECRET_ARN=$(aws secretsmanager describe-secret --secret-id $SECRET_NAME --query 'ARN' --output text)
if [ -z "$SECRET_ARN" ]; then
  echo "Failed to retrieve ARN for secret $SECRET_NAME"
  exit 1
fi

cd ..

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
