# Guia Rápido de Referência - Workshop AWS Serverless

## 🚀 Comandos Essenciais

### AWS CLI
```bash
# Configurar credenciais
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"

# Verificar credenciais
aws sts get-caller-identity

# Ver região configurada
aws configure get region
```

### CDK
```bash
cd cdk

# Bootstrap (apenas primeira vez)
npx cdk bootstrap

# Ver mudanças antes de aplicar
npx cdk diff

# Ver template CloudFormation
npx cdk synth

# Deploy
npx cdk deploy --all

# Deploy sem confirmação
npx cdk deploy --all --require-approval never

# Destruir todos os recursos
npx cdk destroy --all --force
```

### Desenvolvimento Local
```bash
cd webapp

# Instalar dependências
npm ci

# Executar migrations do Prisma
npx prisma db push

# Rodar servidor de desenvolvimento
npm run dev

# Build de produção
npm run build
```

## 📁 Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `cdk/bin/cdk.ts` | Ponto de entrada do CDK |
| `cdk/lib/main-stack.ts` | **Stack principal - MODIFICAR AQUI** |
| `cdk/lib/constructs/` | Componentes AWS reutilizáveis |
| `webapp/src/app/(root)/page.tsx` | Página principal da aplicação |
| `webapp/src/app/(root)/actions.ts` | Server Actions (backend) |
| `webapp/prisma/schema.prisma` | Schema do banco de dados |

## 🔧 Estrutura do Main Stack

```typescript
// cdk/lib/main-stack.ts

// 1. VPC (Rede)
const vpc = new Vpc(this, 'Vpc', {...});

// 2. Database (Aurora PostgreSQL)
const database = new Database(this, 'Database', { vpc });

// 3. Auth (Cognito)
const auth = new Auth(this, 'Auth', {...});

// 4. EventBus (AppSync Events)
const eventBus = new EventBus(this, 'EventBus', {});
eventBus.addUserPoolProvider(auth.userPool);

// 5. AsyncJob (Lambda para jobs)
const asyncJob = new AsyncJob(this, 'AsyncJob', { database, eventBus });

// 6. Webapp (Next.js Lambda)
const webapp = new Webapp(this, 'Webapp', {
  database, auth, eventBus, asyncJob, ...
});
```

## 📊 Outputs Importantes

Após `cdk deploy`, você receberá:

```bash
# URL da aplicação
ServerlessWebappStarterKitStack.FrontendDomainName = https://xxx.cloudfront.net

# Cognito IDs
ServerlessWebappStarterKitStack.AuthUserPoolId = us-east-1_xxx
ServerlessWebappStarterKitStack.AuthUserPoolClientId = xxx

# Comandos úteis
ServerlessWebappStarterKitStack.DatabasePortForwardCommand = aws ssm start-session...
ServerlessWebappStarterKitStack.DatabaseSecretsCommand = aws secretsmanager get-secret-value...
```

## 🎯 Fluxo do Workshop

### Etapa 2A: VPC + Database
```typescript
// Manter apenas:
const vpc = new Vpc(...);
const database = new Database(...);
// Comentar todo o resto
```

### Etapa 2B: + Auth + EventBus
```typescript
// Adicionar:
const auth = new Auth(...);
const eventBus = new EventBus(...);
eventBus.addUserPoolProvider(auth.userPool);
// Manter asyncJob e webapp comentados
```

### Etapa 3: Deploy Completo
```typescript
// Descomentar tudo:
const asyncJob = new AsyncJob(...);
const webapp = new Webapp(...);
```

## 🔧 Comandos Úteis de Debug

```bash
# Ver logs detalhados no deploy
npx cdk deploy --all --verbose

# Ver o que será criado
npx cdk synth

# Verificar credenciais
aws sts get-caller-identity

# Verificar status Docker
docker ps
```

## 📚 Serviços AWS Usados

| Serviço | Uso |
|---------|-----|
| **VPC** | Rede virtual isolada |
| **NAT Instance** | Internet para recursos privados |
| **Aurora Serverless v2** | PostgreSQL serverless |
| **Lambda** | Aplicação Next.js |
| **CloudFront** | CDN global |
| **Cognito** | Autenticação |
| **AppSync Events** | WebSockets real-time |
| **CloudWatch** | Logs e métricas |

## ⚡ Atalhos do VSCode

- `Ctrl + `` ` `: Abrir/fechar terminal
- `Ctrl + P`: Buscar arquivo
- `Ctrl + Shift + P`: Command palette
- `Ctrl + /`: Comentar/descomentar linha
- `Alt + Up/Down`: Mover linha
- `Ctrl + D`: Selecionar próxima ocorrência

## 🔗 Links Úteis

- [AWS CDK Docs](https://docs.aws.amazon.com/cdk/)
- [Next.js Docs](https://nextjs.org/docs)
- [Prisma Docs](https://www.prisma.io/docs)
- [AWS Console](https://console.aws.amazon.com/)

## 📞 Precisa de Ajuda?

1. Consulte os logs no CloudWatch
2. Pergunte ao instrutor
3. Use `cdk synth` para ver o template gerado
4. Verifique credenciais com `aws sts get-caller-identity`

---

**💡 Dica**: Mantenha este arquivo aberto em uma aba separada durante o workshop!
