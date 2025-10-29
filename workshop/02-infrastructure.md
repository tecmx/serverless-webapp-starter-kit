# Etapa 2: Deploy da Infraestrutura Base

[← Voltar](README.md) | [← Anterior: Setup](01-setup.md) | [Próximo: Aplicação →](03-application.md)

---

## ⏱️ Tempo Estimado: 25 minutos

Nesta etapa, você vai implantar a infraestrutura fundamental em duas fases:
- **Fase 2A**: VPC + Aurora Database (10 min)
- **Fase 2B**: Amazon Cognito Auth + EventBus (15 min)

---

## 📋 Visão Geral

### O Que Será Criado

```
Fase 2A:
├── VPC (Virtual Private Cloud)
├── Subnets (públicas e privadas)
├── NAT Instance (para conectividade)
├── Aurora PostgreSQL Serverless v2
└── S3 Bucket (access logs)

Fase 2B:
├── Amazon Cognito User Pool
├── Cognito Client
├── Hosted UI Domain
└── AWS AppSync Events API
```

---

## 2.1 Entender o Main Stack

Abra o arquivo `cdk/lib/main-stack.ts` no VS Code.

### Estrutura do Arquivo

```typescript
export class MainStack extends Stack {
  constructor(scope: Construct, id: string, props: MainStackProps) {
    // 1. VPC
    const vpc = new Vpc(this, 'Vpc', {...});

    // 2. Database
    const database = new Database(this, 'Database', { vpc });

    // 3. Auth
    const auth = new Auth(this, 'Auth', {...});

    // 4. EventBus
    const eventBus = new EventBus(this, 'EventBus', {});

    // 5. AsyncJob
    const asyncJob = new AsyncJob(this, 'AsyncJob', { database, eventBus });

    // 6. Webapp
    const webapp = new Webapp(this, 'Webapp', {...});
  }
}
```

> 💡 **Deployment Incremental**
>
> Vamos comentar partes do código e adicionar gradualmente.
> Isso ajuda a entender como cada componente funciona.

---

## 2.2 Bootstrap do CDK

O bootstrap prepara sua conta AWS para usar o CDK (apenas primeira vez).

```bash
cd cdk
npx cdk bootstrap
```

### O Que o Bootstrap Faz?

- Cria bucket S3 para armazenar assets (imagens Docker, arquivos)
- Cria roles IAM necessárias
- Cria stack CloudFormation chamada `CDKToolkit`

**Saída esperada:**
```
⏳ Bootstrapping environment aws://123456789012/us-east-1...
✅ Environment aws://123456789012/us-east-1 bootstrapped.
```

**Tempo:** 2-3 minutos

> ⚠️ **Importante:** Execute `bootstrap` apenas uma vez por conta/região.

---

## 2.3 Fase 2A: VPC + Database

### Modificar main-stack.ts

Abra `cdk/lib/main-stack.ts` e **comente** temporariamente as seguintes seções:

```typescript
// COMENTAR estas linhas (adicione // no início):

// const auth = new Auth(this, 'Auth', {
//   hostedZone,
//   sharedCertificate: props.sharedCertificate,
// });

// const eventBus = new EventBus(this, 'EventBus', {});
// eventBus.addUserPoolProvider(auth.userPool);

// const asyncJob = new AsyncJob(this, 'AsyncJob', { database: database, eventBus });

// const webapp = new Webapp(this, 'Webapp', {
//   database,
//   hostedZone,
//   certificate: props.sharedCertificate,
//   signPayloadHandler: props.signPayloadHandler,
//   accessLogBucket,
//   auth,
//   eventBus,
//   asyncJob,
//   subDomain: 'web',
// });

// new CfnOutput(this, 'FrontendDomainName', {
//   value: webapp.baseUrl,
// });
```

**Dica:** Use `Ctrl+/` (ou `Cmd+/`) para comentar múltiplas linhas no VS Code.

### Deploy Fase 2A

```bash
npx cdk deploy --all
```

Quando perguntado sobre criar recursos, responda **`y`**.

**Tempo estimado:** 8-10 minutos

### ⏰ Enquanto Aguarda o Deploy...

Vamos entender o que está sendo criado!

---

## 🔍 Conceito: Amazon VPC

### O que é VPC?

**Virtual Private Cloud** - Uma rede virtual isolada na AWS onde seus recursos vivem.

**Analogia:** É como um "condomínio fechado" na nuvem. Você controla quem entra e sai.

### Componentes da VPC

#### 1. **Subnets**
Subdivisões da VPC em diferentes zonas de disponibilidade.

**Tipos:**
- **Públicas**: Têm acesso direto à internet (via Internet Gateway)
  - Usadas para: NAT Instance, Load Balancers
- **Privadas**: Sem acesso direto à internet
  - Usadas para: Database, Lambda functions
- **Isoladas**: Completamente sem internet
  - Usadas para: Dados muito sensíveis

#### 2. **Internet Gateway**
Permite comunicação entre VPC e internet.

#### 3. **NAT Instance**
Permite que recursos privados acessem a internet (ex: downloads, APIs externas).

**Por que NAT Instance em vez de NAT Gateway?**
| | NAT Gateway | NAT Instance |
|---|-------------|--------------|
| **Tipo** | Gerenciado | t3.nano EC2 |
| **Uso** | Produção | Dev/Test |
| **Vantagem** | Alta disponibilidade | Econômico |

#### 4. **Security Groups**
Firewalls virtuais que controlam tráfego de entrada/saída.

### Nossa VPC

```
VPC (10.0.0.0/16)
│
├── Subnet Pública (10.0.0.0/24) - AZ a
│   └── NAT Instance
│
├── Subnet Pública (10.0.1.0/24) - AZ b
│
├── Subnet Privada (10.0.2.0/24) - AZ a
│   ├── Lambda functions
│   └── Aurora Database
│
└── Subnet Privada (10.0.3.0/24) - AZ b
    └── Aurora Database (replica)
```

**Leia mais:** [concepts/vpc.md](concepts/vpc.md)

---

## 🔍 Conceito: Aurora Serverless v2

### O que é?

**Amazon Aurora Serverless v2** - Banco de dados PostgreSQL totalmente gerenciado que escala automaticamente.

**Analogia:** É como ter um elástico que estica e encolhe conforme necessário. Você paga só pelo que usa!

### Características

#### 1. **Serverless** ⚡
- Escala automaticamente de 0.5 a 128 ACUs
- ACU = Aurora Capacity Unit (2GB RAM + CPU proporcional)
- Nosso mínimo: 0.5 ACU (1GB RAM)

#### 2. **Auto-pause** 💤
- Pausa após 5 minutos de inatividade
- Cold start: ~15 segundos
- Ideal para desenvolvimento

#### 3. **Compatibilidade** 🔄
- 100% compatível com PostgreSQL 16
- Use qualquer ferramenta PostgreSQL
- Migrations do Prisma funcionam perfeitamente

#### 4. **Alta Disponibilidade** 🛡️
- Multi-AZ automático
- Backups contínuos
- Point-in-time recovery (até 35 dias)

#### 5. **Performance** 🚀
- Performance Insights incluído
- Monitoring de queries
- Otimização automática

### Nossa Configuração

```typescript
const cluster = new rds.DatabaseCluster(this, 'Cluster', {
  engine: rds.DatabaseClusterEngine.auroraPostgres({
    version: rds.AuroraPostgresEngineVersion.VER_16_6
  }),
  serverlessV2MinCapacity: 0.5,  // Mínimo
  storageEncrypted: true,         // Segurança
  vpc,                            // Rede privada
});
```

**Leia mais:** [concepts/aurora.md](concepts/aurora.md)

---

## ✅ Verificar Deploy Fase 2A

Quando o deploy terminar, você verá:

```
✅  ServerlessWebappStarterKitStack

Outputs:
ServerlessWebappStarterKitStack.DatabasePortForwardCommand = aws ssm start-session...
ServerlessWebappStarterKitStack.DatabaseSecretsCommand = aws secretsmanager get-secret-value...

Stack ARN:
arn:aws:cloudformation:us-east-1:123456789012:stack/ServerlessWebappStarterKitStack/...
```

### Explorar no AWS Console (Opcional)

1. Acesse [CloudFormation Console](https://console.aws.amazon.com/cloudformation)
2. Encontre stack `ServerlessWebappStarterKitStack`
3. Veja tab **Resources** - mais de 30 recursos criados!
4. Veja tab **Outputs** - comandos úteis

---

## 2.4 Fase 2B: Auth + EventBus

Agora vamos adicionar autenticação e o barramento de eventos.

### Descomentar no main-stack.ts

```typescript
// Descomentar (remover //):

const auth = new Auth(this, 'Auth', {
  hostedZone,
  sharedCertificate: props.sharedCertificate,
});

const eventBus = new EventBus(this, 'EventBus', {});
eventBus.addUserPoolProvider(auth.userPool);

// Manter AsyncJob e Webapp comentados!
```

### Deploy Fase 2B

```bash
npx cdk deploy --all
```

**Tempo estimado:** 5-7 minutos

---

## 🔍 Conceito: Amazon Cognito

### O que é?

**Amazon Cognito** - Serviço gerenciado para autenticação e gerenciamento de usuários.

**Analogia:** É como ter um "porteiro virtual" que gerencia quem pode entrar no seu prédio.

### Componentes

#### 1. **User Pool** 👥
Diretório de usuários (como um banco de dados de contas).

**Features:**
- Sign up / Sign in
- Password reset
- Email/SMS verification
- MFA (Multi-Factor Authentication)
- Social login (Google, Facebook)

#### 2. **User Pool Client** 📱
Aplicação que pode acessar o User Pool.

**Nossa configuração:**
- OAuth 2.0 flow
- Authorization Code Grant
- Token validity: 24 horas

#### 3. **Hosted UI** 🎨
Interface de login gerenciada pela AWS.

**Vantagens:**
- Pronta para uso
- Customizável
- Segura por padrão
- Suporte a múltiplos idiomas

### Política de Senha

Nossa configuração requer:
- ✅ Mínimo 8 caracteres
- ✅ Letra maiúscula
- ✅ Letra minúscula
- ✅ Número
- ✅ Símbolo especial

**Exemplo válido:** `MinhaSenh@123`

### OAuth Flow

```
1. Usuário clica "Sign In"
2. Redirecionado para Cognito Hosted UI
3. Usuário faz login
4. Cognito gera tokens (ID, Access, Refresh)
5. Redirecionado de volta para app
6. App valida tokens
7. Usuário autenticado!
```

**Leia mais:** [concepts/cognito.md](concepts/cognito.md)

---

## 🔍 Conceito: AWS AppSync Events

### O que é?

**AppSync Events** - Serviço gerenciado para comunicação em tempo real usando WebSockets.

**Analogia:** É como um "walkie-talkie" entre servidor e clientes. Comunicação bidirecional instantânea.

### Use Cases

- 💬 Chat em tempo real
- 🔔 Notificações push
- 📊 Dashboards ao vivo
- 🎮 Multiplayer games
- 📈 Atualizações de dados

### Componentes

#### 1. **Event API**
Endpoint para publicar e receber eventos.

#### 2. **Channel Namespace**
Organização lógica de canais.

**Nossa namespace:** `event-bus`

#### 3. **Channels**
Canais específicos para comunicação.

**Nosso padrão:** `user/{userId}/jobs`

### Nossa Configuração

```typescript
const api = new appsync.EventApi(this, 'Api', {
  authorizationConfig: {
    authProviders: [
      { authorizationType: appsync.AppSyncAuthorizationType.IAM },
      { authorizationType: appsync.AppSyncAuthorizationType.COGNITO }
    ]
  }
});
```

**Autenticação dupla:**
- **IAM**: Para Lambda functions (backend)
- **Cognito**: Para usuários (frontend)

**Leia mais:** [concepts/appsync.md](concepts/appsync.md)

---

## ✅ Verificar Deploy Fase 2B

Novos outputs aparecerão:

```
Outputs:
ServerlessWebappStarterKitStack.AuthUserPoolId = us-east-1_xxxxx
ServerlessWebappStarterKitStack.AuthUserPoolClientId = xxxxxxxxxxxxx
ServerlessWebappStarterKitStack.AuthUserPoolDomainName = https://webapp-xxxxx.auth.us-east-1.amazoncognito.com
ServerlessWebappStarterKitStack.EventBusHttpEndpoint = https://xxxxx.appsync-api.us-east-1.amazonaws.com
```

Guarde esses valores - você vai usá-los depois!

---

## 📊 Resumo da Etapa

### O Que Foi Criado

**Fase 2A:**
- ✅ VPC com 4 subnets (2 públicas, 2 privadas)
- ✅ Internet Gateway
- ✅ NAT Instance (t4g.nano)
- ✅ Aurora PostgreSQL Serverless v2
- ✅ Security Groups
- ✅ S3 Bucket para logs

**Fase 2B:**
- ✅ Cognito User Pool
- ✅ Cognito User Pool Client
- ✅ Cognito Domain (Hosted UI)
- ✅ AppSync Events API
- ✅ Channel Namespace

### Recursos AWS Criados

**Total: ~40 recursos CloudFormation**

---

## 🎉 Próxima Etapa

Excelente! Você tem a infraestrutura base rodando.

**Agora vamos deployar a aplicação web!**

👉 **[Etapa 3: Deploy da Aplicação Web →](03-application.md)**

---

[← Voltar](README.md) | [← Anterior: Setup](01-setup.md) | [Próximo: Aplicação →](03-application.md)

**Tempo desta etapa:** 25 minutos ⏱️
