# 💡 LocalStack - Exemplos Práticos

Exemplos práticos de uso do LocalStack para desenvolvimento diário.

## 🚀 Workflows Comuns

### Workflow 1: Desenvolvimento de Nova Feature

```bash
# 1. Iniciar ambiente
make start

# 2. Fazer mudanças no código
vim cdk/lib/main-stack.ts
vim webapp/src/app/page.tsx

# 3. Deploy das mudanças
make deploy

# 4. Testar
make logs  # Verificar logs

# 5. Iterar
# Voltar ao passo 2 até estar satisfeito
```

### Workflow 2: Testar Lambda Functions

```bash
# 1. Deploy
make deploy

# 2. Listar funções
make list-lambda

# 3. Invocar uma função
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name MeuFunctionName \
  --payload '{"key":"value"}' \
  response.json

# 4. Ver resultado
cat response.json

# 5. Ver logs
aws --endpoint-url=http://localhost:4566 logs tail \
  /aws/lambda/MeuFunctionName
```

### Workflow 3: Testar S3 Operations

```bash
# 1. Criar bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://meu-bucket-teste

# 2. Upload de arquivo
echo "Hello LocalStack" > test.txt
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://meu-bucket-teste/

# 3. Listar objetos
aws --endpoint-url=http://localhost:4566 s3 ls s3://meu-bucket-teste/

# 4. Download de arquivo
aws --endpoint-url=http://localhost:4566 s3 cp s3://meu-bucket-teste/test.txt downloaded.txt

# 5. Deletar bucket
aws --endpoint-url=http://localhost:4566 s3 rb s3://meu-bucket-teste --force
```

### Workflow 4: Debug de Deploy

```bash
# 1. Deploy com output verbose
cd cdk
USE_LOCALSTACK=true npx cdklocal deploy --all --require-approval never --verbose

# 2. Se falhar, ver logs do LocalStack
make logs-localstack

# 3. Ver stacks do CloudFormation
make list-stacks

# 4. Ver detalhes de uma stack
aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
  --stack-name ServerlessWebappStarterKitStack

# 5. Ver recursos de uma stack
aws --endpoint-url=http://localhost:4566 cloudformation list-stack-resources \
  --stack-name ServerlessWebappStarterKitStack
```

### Workflow 5: Reset Completo

```bash
# Quando algo der muito errado

# 1. Destruir recursos
make destroy

# 2. Parar e limpar tudo
make clean

# 3. Reiniciar do zero
make start
make init
make deploy
```

## 🔧 Comandos Úteis por Serviço

### S3

```bash
# Listar todos os buckets
./awslocal.sh s3 ls

# Criar bucket
./awslocal.sh s3 mb s3://my-bucket

# Upload com metadata
./awslocal.sh s3 cp file.txt s3://my-bucket/ \
  --metadata key1=value1,key2=value2

# Sync diretório
./awslocal.sh s3 sync ./local-dir s3://my-bucket/remote-dir/

# Presigned URL
./awslocal.sh s3 presign s3://my-bucket/file.txt --expires-in 3600
```

### Lambda

```bash
# Listar funções
./awslocal.sh lambda list-functions

# Obter configuração
./awslocal.sh lambda get-function --function-name MyFunction

# Invocar síncrono
./awslocal.sh lambda invoke \
  --function-name MyFunction \
  --payload '{"key":"value"}' \
  response.json

# Invocar assíncrono
./awslocal.sh lambda invoke \
  --function-name MyFunction \
  --invocation-type Event \
  --payload '{"key":"value"}' \
  response.json

# Ver logs
./awslocal.sh logs tail /aws/lambda/MyFunction --follow
```

### Cognito

```bash
# Listar user pools
./awslocal.sh cognito-idp list-user-pools --max-results 10

# Criar usuário
./awslocal.sh cognito-idp admin-create-user \
  --user-pool-id us-west-2_xxxxxx \
  --username testuser \
  --temporary-password TempPass123!

# Listar usuários
./awslocal.sh cognito-idp list-users \
  --user-pool-id us-west-2_xxxxxx

# Confirmar usuário
./awslocal.sh cognito-idp admin-confirm-sign-up \
  --user-pool-id us-west-2_xxxxxx \
  --username testuser
```

### Secrets Manager

```bash
# Criar secret
./awslocal.sh secretsmanager create-secret \
  --name MySecret \
  --secret-string '{"user":"admin","pass":"secret"}'

# Listar secrets
./awslocal.sh secretsmanager list-secrets

# Obter secret
./awslocal.sh secretsmanager get-secret-value --secret-id MySecret

# Atualizar secret
./awslocal.sh secretsmanager update-secret \
  --secret-id MySecret \
  --secret-string '{"user":"admin","pass":"newsecret"}'

# Deletar secret
./awslocal.sh secretsmanager delete-secret \
  --secret-id MySecret \
  --force-delete-without-recovery
```

### EventBridge

```bash
# Listar event buses
./awslocal.sh events list-event-buses

# Criar regra
./awslocal.sh events put-rule \
  --name MyRule \
  --event-pattern '{"source":["my.app"]}'

# Listar regras
./awslocal.sh events list-rules

# Put evento customizado
./awslocal.sh events put-events \
  --entries '[{
    "Source": "my.app",
    "DetailType": "myDetailType",
    "Detail": "{\"key\":\"value\"}"
  }]'
```

### CloudFormation

```bash
# Listar todas as stacks
./awslocal.sh cloudformation list-stacks

# Descrever stack
./awslocal.sh cloudformation describe-stacks \
  --stack-name MyStack

# Listar recursos da stack
./awslocal.sh cloudformation list-stack-resources \
  --stack-name MyStack

# Obter template
./awslocal.sh cloudformation get-template \
  --stack-name MyStack

# Deletar stack
./awslocal.sh cloudformation delete-stack \
  --stack-name MyStack
```

## 🎯 Scripts de Automação

### Script: Popular Dados de Teste

```bash
#!/bin/bash
# seed-data.sh

source localstack.env

echo "📦 Populando dados de teste..."

# Criar usuário de teste
./awslocal.sh cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username testuser@example.com \
  --user-attributes Name=email,Value=testuser@example.com \
  --temporary-password Test123!

# Upload de arquivos de teste
./awslocal.sh s3 cp test-data/ s3://my-bucket/test-data/ --recursive

# Criar secrets de teste
./awslocal.sh secretsmanager create-secret \
  --name test/api-key \
  --secret-string "test-api-key-12345"

echo "✅ Dados de teste populados!"
```

### Script: Backup do LocalStack

```bash
#!/bin/bash
# backup-localstack.sh

BACKUP_DIR="./localstack-backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "💾 Criando backup do LocalStack..."

# Parar containers
docker-compose stop

# Copiar volumes
cp -r ./volume "$BACKUP_DIR/"

# Exportar stacks
./awslocal.sh cloudformation list-stacks \
  --query 'StackSummaries[*].StackName' \
  --output text | while read stack; do
    ./awslocal.sh cloudformation get-template \
      --stack-name "$stack" \
      > "$BACKUP_DIR/${stack}.json"
done

# Reiniciar containers
docker-compose start

echo "✅ Backup criado em: $BACKUP_DIR"
```

### Script: Verificar Health

```bash
#!/bin/bash
# health-check.sh

echo "🏥 Verificando saúde do ambiente..."

# Check LocalStack
if curl -sf http://localhost:4566/_localstack/health > /dev/null; then
    echo "✅ LocalStack: OK"
else
    echo "❌ LocalStack: FALHOU"
    exit 1
fi

# Check PostgreSQL
if docker-compose exec -T postgres pg_isready -U root > /dev/null 2>&1; then
    echo "✅ PostgreSQL: OK"
else
    echo "❌ PostgreSQL: FALHOU"
    exit 1
fi

# Check CDK stacks
STACKS=$(./awslocal.sh cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
  --query 'length(StackSummaries)' \
  --output text)

if [ "$STACKS" -gt 0 ]; then
    echo "✅ CDK Stacks: $STACKS stacks deployadas"
else
    echo "⚠️  CDK Stacks: Nenhuma stack encontrada"
fi

echo "✅ Health check completo!"
```

## 🧪 Testes de Integração

### Exemplo: Testar API Gateway + Lambda

```bash
# 1. Deploy da API
make deploy

# 2. Obter URL da API
API_ID=$(./awslocal.sh apigateway get-rest-apis \
  --query 'items[0].id' --output text)
API_URL="http://localhost:4566/restapis/${API_ID}/prod/_user_request_"

# 3. Testar endpoint
curl -X GET "${API_URL}/api/todos"

# 4. Criar item
curl -X POST "${API_URL}/api/todos" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Todo","completed":false}'

# 5. Verificar logs
./awslocal.sh logs tail /aws/lambda/TodosFunction --follow
```

### Exemplo: Testar S3 Event Trigger

```bash
# 1. Criar bucket com notificação
./awslocal.sh s3 mb s3://test-events

# 2. Configurar notificação (via CDK ou manualmente)
# Ver CDK stack

# 3. Upload de arquivo para triggerar evento
echo "test" > trigger.txt
./awslocal.sh s3 cp trigger.txt s3://test-events/

# 4. Verificar se Lambda foi invocada
./awslocal.sh logs tail /aws/lambda/S3TriggerFunction
```

## 📊 Monitoramento e Debug

### Ver Logs em Tempo Real

```bash
# Todos os logs
make logs

# Apenas LocalStack (mais detalhado)
docker-compose logs -f localstack | grep -i error

# Apenas uma função Lambda
./awslocal.sh logs tail /aws/lambda/MyFunction --follow
```

### Inspecionar Estado

```bash
# Ver todos os recursos criados
./awslocal.sh resourcegroupstaggingapi get-resources

# Ver métricas (se suportado)
./awslocal.sh cloudwatch list-metrics

# Ver alarmes
./awslocal.sh cloudwatch describe-alarms
```

### Debug de Lambda

```bash
# Adicionar logs na função
# Exemplo em Node.js:
console.log('DEBUG:', JSON.stringify(event));
console.log('Context:', JSON.stringify(context));

# Redeploy
make deploy

# Invocar e ver logs
./awslocal.sh lambda invoke \
  --function-name MyFunction \
  --log-type Tail \
  --payload '{"test":"data"}' \
  response.json

# Logs vêm em Base64 no output
```

## 🎨 Dicas Pro

### Alias Úteis

```bash
# Adicione ao ~/.bashrc ou ~/.zshrc

# LocalStack AWS CLI
alias awsl='aws --endpoint-url=http://localhost:4566'

# Comandos comuns
alias lstack-s3='awsl s3 ls'
alias lstack-lambda='awsl lambda list-functions'
alias lstack-logs='awsl logs tail'
alias lstack-stacks='awsl cloudformation list-stacks'

# Make shortcuts
alias lstart='make start'
alias lstop='make stop'
alias ldeploy='make deploy'
alias lclean='make clean'
```

### Função para Logs de Lambda

```bash
# Adicione ao ~/.bashrc ou ~/.zshrc
function lambda-logs() {
  aws --endpoint-url=http://localhost:4566 \
    logs tail "/aws/lambda/$1" --follow
}

# Uso: lambda-logs MyFunctionName
```

### Função para Invocar Lambda

```bash
# Adicione ao ~/.bashrc ou ~/.zshrc
function lambda-invoke() {
  local func_name=$1
  local payload=${2:-'{}'}

  aws --endpoint-url=http://localhost:4566 \
    lambda invoke \
    --function-name "$func_name" \
    --payload "$payload" \
    response.json

  cat response.json
  echo ""
}

# Uso: lambda-invoke MyFunction '{"key":"value"}'
```

## 📚 Recursos Adicionais

### LocalStack UI (Pro Feature)

Se você tem LocalStack Pro:

```bash
# Acessar UI
open http://localhost:4566/_localstack/dashboard
```

### Ferramentas Úteis

```bash
# awslocal (alternativa ao nosso script)
pip install awscli-local

# LocalStack CLI
pip install localstack

# Verificar status
localstack status

# Ver logs
localstack logs
```

## 🎯 Próximos Passos

1. Experimente os workflows comuns
2. Crie seus próprios scripts de automação
3. Adapte os exemplos para seu caso de uso
4. Documente seus próprios workflows

---

**💡 Dica:** Combine estes exemplos com o Makefile para criar workflows ainda mais eficientes!
