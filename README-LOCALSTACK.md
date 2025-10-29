# Desenvolvimento Local com LocalStack

Este guia mostra como executar o projeto localmente usando LocalStack ao invés de uma conta AWS real.

## 📋 Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) e Docker Compose
- [Node.js](https://nodejs.org/en/download/) (>= v20)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

> 🔍 **Verificação de Setup**
>
> Após seguir este guia, use o [Checklist de Verificação](LOCALSTACK-VERIFICATION.md) para confirmar que tudo está funcionando corretamente.

## 🚀 Início Rápido

### Método 1: Usando Makefile (Recomendado) ⭐

```bash
# Ver todos os comandos disponíveis
make help

# Setup completo (instala dependências)
make setup

# Inicializar ambiente (inicia containers e configura)
make init

# Fazer deploy
make deploy
```

Pronto! O ambiente está configurado e rodando.

### Método 2: Manual

### 1. Iniciar LocalStack e PostgreSQL

```bash
# Na raiz do projeto
docker-compose up -d

# Ou usando make
make start
```

Isso iniciará:
- **LocalStack** na porta 4566 (simula serviços AWS)
- **PostgreSQL** na porta 5432 (banco de dados)

### 2. Verificar Status dos Serviços

```bash
# Verificar se os containers estão rodando
docker-compose ps

# Verificar health do LocalStack
curl http://localhost:4566/_localstack/health

# Ou usando make
make status
```

### 3. Configurar Ambiente

```bash
# Opção A: Executar o script de inicialização
./localstack-init.sh

# Opção B: Carregar variáveis de ambiente do arquivo
cp localstack.env.example localstack.env
source localstack.env

# Opção C: Configurar manualmente
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-west-2
export AWS_ENDPOINT_URL=http://localhost:4566
export USE_LOCALSTACK=true
```

### 4. Instalar Dependências

```bash
cd cdk
npm ci

# Ou usando make (volta para raiz primeiro)
cd ..
make setup-cdk
```

### 5. Deploy no LocalStack

```bash
# Ainda no diretório cdk/
npm run deploy:local

# Ou da raiz usando make
make deploy
```

Este comando irá:
1. Executar o bootstrap do CDK no LocalStack
2. Fazer o deploy de todas as stacks
3. Criar todos os recursos AWS simulados

## 🔧 Comandos Úteis

### Comandos do Makefile

```bash
# Ver todos os comandos disponíveis
make help

# Gerenciamento de containers
make start          # Inicia LocalStack e PostgreSQL
make stop           # Para todos os serviços
make restart        # Reinicia todos os serviços
make status         # Mostra status dos serviços
make clean          # Para e remove tudo (incluindo volumes)

# Desenvolvimento
make init           # Inicializa o ambiente completo
make deploy         # Deploy no LocalStack
make destroy        # Destroi recursos no LocalStack
make setup          # Instala todas as dependências
make setup-cdk      # Instala apenas dependências do CDK
make setup-webapp   # Instala apenas dependências da webapp
make dev-webapp     # Inicia webapp em modo desenvolvimento

# Logs
make logs                # Logs de todos os serviços
make logs-localstack     # Logs apenas do LocalStack
make logs-postgres       # Logs apenas do PostgreSQL

# Shell
make shell-localstack    # Abre shell no container LocalStack
make shell-postgres      # Abre psql no PostgreSQL

# AWS CLI (LocalStack)
make list-s3         # Lista buckets S3
make list-lambda     # Lista funções Lambda
make list-cognito    # Lista User Pools do Cognito
make list-stacks     # Lista stacks do CloudFormation
```

### Comandos Diretos (sem Makefile)

```bash
# Deploy no LocalStack
cd cdk
npm run deploy:local

# Destruir recursos no LocalStack
npm run destroy:local

# Visualizar logs do LocalStack
docker-compose logs -f localstack

# Visualizar logs do PostgreSQL
docker-compose logs -f postgres
```

### Interagir com Serviços LocalStack

```bash
# Listar buckets S3
aws --endpoint-url=http://localhost:4566 s3 ls

# Listar funções Lambda
aws --endpoint-url=http://localhost:4566 lambda list-functions

# Listar user pools do Cognito
aws --endpoint-url=http://localhost:4566 cognito-idp list-user-pools --max-results 10

# Listar secrets no Secrets Manager
aws --endpoint-url=http://localhost:4566 secretsmanager list-secrets

# Listar stacks do CloudFormation
aws --endpoint-url=http://localhost:4566 cloudformation list-stacks
```

### Gerenciamento de Containers

```bash
# Parar todos os serviços
docker-compose stop

# Iniciar serviços parados
docker-compose start

# Reiniciar serviços
docker-compose restart

# Parar e remover containers (mantém volumes)
docker-compose down

# Parar e remover tudo (incluindo volumes)
docker-compose down -v
```

## 📝 Desenvolvimento da Aplicação Web

Para desenvolver a aplicação Next.js localmente:

```bash
cd webapp
npm ci

# Copiar arquivo de exemplo e configurar
cp .env.local.example .env.local
# Edite .env.local com as configurações do LocalStack

# Executar em modo de desenvolvimento
npm run dev
```

A aplicação estará disponível em `http://localhost:3000`.

## 🔍 Diferenças do LocalStack vs AWS Real

### Recursos Suportados

O LocalStack simula os principais serviços AWS, mas com algumas limitações:

✅ **Totalmente Suportado:**
- S3 (armazenamento de objetos)
- Lambda (funções serverless)
- CloudFormation (IaC)
- IAM (gerenciamento de identidade - básico)
- Secrets Manager (gerenciamento de secrets)
- SSM Parameter Store (parâmetros)
- EventBridge (event bus)
- CloudWatch Logs (logs básicos)

⚠️ **Parcialmente Suportado:**
- Cognito (autenticação - funcionalidades básicas)
- AppSync (APIs GraphQL/Events - pode ter limitações)
- RDS (apenas emulação, usa PostgreSQL local)
- CloudFront (funcionalidade limitada)
- Lambda@Edge (pode não funcionar completamente)

❌ **Não Suportado / Limitado:**
- Route53 (DNS management)
- ACM (Certificate Manager)
- CloudFront + Lambda@Edge (streaming response)
- VPC complexa (NAT Gateway, etc.)

### Configurações Desabilitadas no LocalStack

Quando `USE_LOCALSTACK=true`, as seguintes features são automaticamente desabilitadas:

- **Custom Domain Names**: Domínios personalizados não são configurados
- **Route53**: Zonas hospedadas não são criadas
- **ACM**: Certificados SSL não são criados
- **CloudFront**: CDN não é configurada completamente

## 🐛 Troubleshooting

### LocalStack não inicia

```bash
# Verificar logs
docker-compose logs localstack

# Parar tudo e limpar
docker-compose down -v
docker-compose up -d
```

### Deploy falha no LocalStack

```bash
# Limpar cache do CDK
cd cdk
rm -rf cdk.out/

# Tentar novamente
npm run deploy:local
```

### PostgreSQL não conecta

```bash
# Verificar se o container está rodando
docker-compose ps postgres

# Verificar logs
docker-compose logs postgres

# Testar conexão
docker-compose exec postgres psql -U root -c "SELECT 1"
```

### Limpar Estado do LocalStack

```bash
# Parar containers
docker-compose down

# Remover volume do LocalStack
rm -rf ./volume

# Iniciar novamente
docker-compose up -d
```

## 💡 Dicas de Desenvolvimento

### 1. Persistência de Dados

O LocalStack está configurado com `PERSISTENCE=1`, então seus dados serão mantidos entre restarts dos containers (armazenados em `./volume/`).

### 2. Debug

Para habilitar logs detalhados do LocalStack:

```bash
# Edite compose.yaml e altere:
DEBUG=1  # ao invés de DEBUG=0

# Reinicie
docker-compose restart localstack
```

### 3. Performance

Se o LocalStack estiver lento:

```bash
# Aumente recursos do Docker
# Docker Desktop -> Settings -> Resources
# Recomendado: 4GB+ RAM, 2+ CPUs
```

### 4. Desenvolvimento Híbrido

Você pode usar LocalStack para alguns serviços e AWS real para outros:

```bash
# Deploy parcial apenas para dev
export USE_LOCALSTACK=false
cd cdk
npx cdk deploy DatabaseStack  # Deploy apenas o database na AWS
```

## 🌐 Endpoints Importantes

| Serviço | Endpoint Local |
|---------|---------------|
| LocalStack Gateway | http://localhost:4566 |
| PostgreSQL | localhost:5432 |
| Web App (dev) | http://localhost:3000 |
| LocalStack Dashboard | http://localhost:4566/_localstack/health |

## 📚 Recursos Adicionais

- [LocalStack Documentation](https://docs.localstack.cloud/overview/)
- [AWS CDK Local (cdklocal)](https://github.com/localstack/aws-cdk-local)
- [LocalStack Services Coverage](https://docs.localstack.cloud/references/coverage/)
- [LocalStack GitHub](https://github.com/localstack/localstack)

## ⚡ Próximos Passos

Após configurar o ambiente local:

1. Explore a aplicação de exemplo
2. Modifique o código e veja as mudanças
3. Teste features sem custo AWS
4. Quando estiver pronto, faça deploy na AWS real seguindo o [README.md](./README.md) principal

## 🤝 Contribuindo

Se encontrar problemas ou tiver sugestões de melhorias para o ambiente local, por favor abra uma issue no repositório!
