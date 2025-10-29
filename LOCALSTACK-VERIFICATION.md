# ✅ LocalStack - Checklist de Verificação

Use este checklist para verificar se o ambiente LocalStack está configurado corretamente.

## 📋 Pré-requisitos

```bash
# Verificar se Docker está instalado
docker --version
# ✅ Esperado: Docker version 20.x ou superior

# Verificar se Docker Compose está instalado
docker-compose --version
# ✅ Esperado: Docker Compose version 2.x ou superior

# Verificar se Node.js está instalado
node --version
# ✅ Esperado: v20.x ou superior

# Verificar se AWS CLI está instalado
aws --version
# ✅ Esperado: aws-cli/2.x ou superior
```

## 🚀 Teste de Inicialização

### 1. Verificar Arquivos Criados

```bash
# Da raiz do projeto
ls -la | grep -E "(Makefile|localstack|README-LOCALSTACK)"
```

**Esperado:**
```
✅ Makefile
✅ localstack-init.sh
✅ localstack.env.example
✅ README-LOCALSTACK.md
✅ QUICK-START-LOCALSTACK.md
✅ awslocal.sh
```

### 2. Iniciar Serviços

```bash
make start
```

**Esperado:**
```
✅ Container localstack iniciado
✅ Container postgres iniciado
```

Verificar:
```bash
docker-compose ps
```

**Esperado:**
```
NAME         STATUS
localstack   Up (healthy)
postgres     Up
```

### 3. Verificar LocalStack

```bash
make status
```

**Esperado:**
```
✅ LocalStack está rodando
```

Ou manualmente:
```bash
curl http://localhost:4566/_localstack/health
```

**Esperado:**
```json
{
  "services": {
    "s3": "available",
    "lambda": "available",
    ...
  }
}
```

### 4. Verificar PostgreSQL

```bash
docker-compose exec postgres pg_isready -U root
```

**Esperado:**
```
✅ /var/run/postgresql:5432 - accepting connections
```

## 🔧 Teste de Deploy

### 1. Instalar Dependências

```bash
cd cdk
npm ci
cd ..
```

**Esperado:**
```
✅ Dependências instaladas sem erros
```

Verificar:
```bash
cd cdk
npm list aws-cdk-local
```

**Esperado:**
```
✅ aws-cdk-local@2.x
```

### 2. Configurar Ambiente

```bash
source localstack.env.example
```

**Esperado:**
```
✅ Variáveis de ambiente LocalStack configuradas!
```

Verificar:
```bash
echo $AWS_ENDPOINT_URL
echo $USE_LOCALSTACK
```

**Esperado:**
```
✅ http://localhost:4566
✅ true
```

### 3. Executar Bootstrap

```bash
cd cdk
USE_LOCALSTACK=true npx cdklocal bootstrap
```

**Esperado:**
```
✅ Bootstrap completo sem erros
✅ Stack CDKToolkit criada
```

### 4. Tentar Deploy (Teste Inicial)

```bash
USE_LOCALSTACK=true npx cdklocal deploy --all --require-approval never
```

**Esperado:**
```
✅ Stacks começam a ser criadas
✅ CloudFormation templates gerados
```

**Nota:** O deploy completo pode falhar em alguns recursos (esperado, devido às limitações do LocalStack). O importante é que o processo comece sem erros de configuração.

## 🧪 Testes de Funcionalidade

### 1. Testar AWS CLI com LocalStack

```bash
# Listar buckets S3
aws --endpoint-url=http://localhost:4566 s3 ls

# Ou usando o wrapper
./awslocal.sh s3 ls
```

**Esperado:**
```
✅ Comando executa sem erro
✅ Lista vazia ou buckets existentes
```

### 2. Verificar CloudFormation

```bash
make list-stacks
```

**Esperado:**
```
✅ Lista de stacks (pode estar vazia inicialmente)
```

### 3. Testar Makefile

```bash
# Verificar comandos disponíveis
make help
```

**Esperado:**
```
✅ Lista de todos os comandos make
✅ Descrições claras
```

Testar alguns comandos:
```bash
make status    # ✅ Deve mostrar status
make logs      # ✅ Deve mostrar logs (Ctrl+C para sair)
```

## 🎯 Checklist Final

Marque cada item após verificar:

### Infraestrutura
- [ ] Docker instalado e rodando
- [ ] Docker Compose funcionando
- [ ] LocalStack container iniciado e saudável
- [ ] PostgreSQL container iniciado e aceitando conexões
- [ ] Porta 4566 acessível (LocalStack)
- [ ] Porta 5432 acessível (PostgreSQL)

### Configuração
- [ ] Arquivos de configuração criados
- [ ] Scripts executáveis (localstack-init.sh, awslocal.sh)
- [ ] Variáveis de ambiente configuráveis
- [ ] .gitignore atualizado

### CDK
- [ ] Dependências CDK instaladas
- [ ] aws-cdk-local instalado
- [ ] Scripts npm funcionando (deploy:local, destroy:local)
- [ ] cdk/bin/cdk.ts detecta USE_LOCALSTACK

### Comandos
- [ ] `make help` funciona
- [ ] `make start` funciona
- [ ] `make stop` funciona
- [ ] `make status` funciona
- [ ] `make logs` funciona
- [ ] AWS CLI com --endpoint-url funciona
- [ ] ./awslocal.sh funciona

### Documentação
- [ ] README-LOCALSTACK.md criado e completo
- [ ] QUICK-START-LOCALSTACK.md criado
- [ ] CHANGELOG-LOCALSTACK.md criado
- [ ] README.md principal atualizado

## 🐛 Troubleshooting

### Se algo não funcionar:

#### LocalStack não inicia
```bash
# Verificar logs
docker-compose logs localstack

# Tentar reiniciar
make clean
make start
```

#### Porta já em uso
```bash
# Verificar o que está usando a porta
sudo lsof -i :4566
sudo lsof -i :5432

# Parar processo ou mudar porta no compose.yaml
```

#### npm ci falha
```bash
# Limpar cache
cd cdk
rm -rf node_modules package-lock.json
npm install
```

#### AWS CLI não encontra endpoint
```bash
# Verificar variáveis de ambiente
echo $AWS_ENDPOINT_URL

# Reconfigurar
export AWS_ENDPOINT_URL=http://localhost:4566
```

#### Deploy falha completamente
```bash
# Verificar se LocalStack está rodando
curl http://localhost:4566/_localstack/health

# Limpar e tentar novamente
cd cdk
rm -rf cdk.out
USE_LOCALSTACK=true npx cdklocal bootstrap
USE_LOCALSTACK=true npx cdklocal deploy --all --require-approval never
```

## 📊 Resultados Esperados

### ✅ Sucesso Total
- Todos os checks passam
- LocalStack responde
- Deploy inicia sem erros de configuração
- AWS CLI funciona com LocalStack

### ⚠️ Sucesso Parcial
- LocalStack roda mas alguns serviços limitados
- Deploy parcial (esperado devido a limitações)
- Alguns recursos não suportados (Route53, ACM)

### ❌ Falha
- LocalStack não inicia
- Erros de configuração no CDK
- AWS CLI não consegue conectar
- → Revisar troubleshooting e documentação

## 🎉 Próximos Passos

Se todos os checks passaram:

1. ✅ **Ambiente funcionando!**
2. 📖 Ler [README-LOCALSTACK.md](README-LOCALSTACK.md) para detalhes
3. 🚀 Começar a desenvolver localmente
4. 🧪 Testar suas mudanças sem custos
5. ☁️ Deploy na AWS real quando pronto

## 📝 Notas

### Limitações Conhecidas (Esperadas)
- CloudFront pode não funcionar completamente
- Lambda@Edge limitado
- Route53 não suportado (domínios customizados desabilitados)
- Cognito com features básicas
- RDS Aurora simulado com PostgreSQL simples

### Essas limitações são **normais e esperadas** quando usando LocalStack!

## 🆘 Precisa de Ajuda?

1. 📖 Consulte [README-LOCALSTACK.md](README-LOCALSTACK.md)
2. 🔍 Veja [CHANGELOG-LOCALSTACK.md](CHANGELOG-LOCALSTACK.md)
3. 🌐 Consulte [LocalStack Docs](https://docs.localstack.cloud/)
4. 💬 Abra uma issue no repositório

---

**Status do Ambiente:**

- [ ] ✅ Tudo funcionando perfeitamente
- [ ] ⚠️ Funcionando com limitações esperadas
- [ ] ❌ Precisa de correções

**Data de Verificação:** __________

**Notas adicionais:**
```
[Adicione suas observações aqui]
```

---

**🎯 Lembre-se:** O LocalStack é uma ferramenta de desenvolvimento. Algumas limitações são esperadas e normais!
