.PHONY: help start stop restart logs status deploy destroy clean init

# Cores para output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

# Docker Compose command (v2 uses 'docker compose', v1 uses 'docker-compose')
DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null || echo "docker compose")

help: ## Mostra esta mensagem de ajuda
	@echo "$(BLUE)LocalStack Development Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

start: ## Inicia LocalStack e PostgreSQL
	@echo "$(BLUE)🚀 Iniciando serviços...$(NC)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✅ Serviços iniciados!$(NC)"
	@make status

stop: ## Para todos os serviços
	@echo "$(YELLOW)⏸️  Parando serviços...$(NC)"
	@$(DOCKER_COMPOSE) stop
	@echo "$(GREEN)✅ Serviços parados!$(NC)"

restart: ## Reinicia todos os serviços
	@echo "$(YELLOW)🔄 Reiniciando serviços...$(NC)"
	@$(DOCKER_COMPOSE) restart
	@echo "$(GREEN)✅ Serviços reiniciados!$(NC)"

logs: ## Mostra logs dos serviços
	@$(DOCKER_COMPOSE) logs -f

logs-localstack: ## Mostra apenas logs do LocalStack
	@$(DOCKER_COMPOSE) logs -f localstack

logs-postgres: ## Mostra apenas logs do PostgreSQL
	@$(DOCKER_COMPOSE) logs -f postgres

status: ## Mostra status dos serviços
	@echo "$(BLUE)📊 Status dos serviços:$(NC)"
	@$(DOCKER_COMPOSE) ps
	@echo ""
	@echo "$(BLUE)🏥 Health do LocalStack:$(NC)"
	@curl -s http://localhost:4566/_localstack/health | grep -q "available" && echo "$(GREEN)✅ LocalStack está rodando$(NC)" || echo "$(YELLOW)⚠️  LocalStack não está pronto$(NC)"

init: start ## Inicializa o ambiente completo
	@echo "$(BLUE)🔧 Inicializando ambiente...$(NC)"
	@./localstack-init.sh

deploy: ## Faz deploy no LocalStack
	@echo "$(BLUE)🚀 Fazendo deploy no LocalStack...$(NC)"
	@cd cdk && npm run deploy:local

destroy: ## Destroi recursos no LocalStack
	@echo "$(YELLOW)💣 Destruindo recursos...$(NC)"
	@cd cdk && npm run destroy:local

clean: stop ## Para serviços e remove volumes
	@echo "$(YELLOW)🧹 Limpando ambiente...$(NC)"
	@$(DOCKER_COMPOSE) down -v
	@rm -rf volume/
	@echo "$(GREEN)✅ Ambiente limpo!$(NC)"

shell-localstack: ## Abre shell no container do LocalStack
	@$(DOCKER_COMPOSE) exec localstack bash

shell-postgres: ## Abre psql no PostgreSQL
	@$(DOCKER_COMPOSE) exec postgres psql -U root

list-s3: ## Lista buckets S3
	@aws --endpoint-url=http://localhost:4566 s3 ls

list-lambda: ## Lista funções Lambda
	@aws --endpoint-url=http://localhost:4566 lambda list-functions --query 'Functions[*].FunctionName' --output table

list-cognito: ## Lista User Pools do Cognito
	@aws --endpoint-url=http://localhost:4566 cognito-idp list-user-pools --max-results 10 --query 'UserPools[*].[Id,Name]' --output table

list-stacks: ## Lista stacks do CloudFormation
	@aws --endpoint-url=http://localhost:4566 cloudformation list-stacks --query 'StackSummaries[?StackStatus!=`DELETE_COMPLETE`].[StackName,StackStatus]' --output table

setup-cdk: ## Instala dependências do CDK
	@echo "$(BLUE)📦 Instalando dependências do CDK...$(NC)"
	@cd cdk && npm ci
	@echo "$(GREEN)✅ Dependências instaladas!$(NC)"

setup-webapp: ## Instala dependências da webapp
	@echo "$(BLUE)📦 Instalando dependências da webapp...$(NC)"
	@cd webapp && npm ci
	@echo "$(GREEN)✅ Dependências instaladas!$(NC)"

setup: setup-cdk setup-webapp ## Instala todas as dependências
	@echo "$(GREEN)✅ Setup completo!$(NC)"

dev-webapp: ## Inicia webapp em modo de desenvolvimento
	@cd webapp && npm run dev
