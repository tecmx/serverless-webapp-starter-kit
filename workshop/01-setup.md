# Etapa 1: Configuração Inicial

[← Voltar](README.md) | [Próximo: Infraestrutura →](02-infrastructure.md)

---

## ⏱️ Tempo Estimado: 15 minutos

Nesta etapa, você vai preparar seu ambiente de desenvolvimento e configurar as ferramentas necessárias.

---

## 1.1 Acessar o GitHub Codespaces

### Passos

1. Acesse o repositório do workshop no GitHub
2. Clique no botão **Code** → **Codespaces** → **Create codespace on main**
3. Aguarde o ambiente ser provisionado (2-3 minutos)

### O Que Está Incluído

O Codespaces já vem com todas as ferramentas necessárias:

- ✅ **Node.js v22** - Runtime JavaScript/TypeScript
- ✅ **AWS CLI** - Interface de linha de comando para AWS
- ✅ **Docker** - Para build de imagens Lambda
- ✅ **TypeScript** - Linguagem do projeto
- ✅ **VS Code** - Editor configurado

### Extensões VS Code Pré-instaladas

- ESLint - Linting de código
- Prettier - Formatação automática
- Tailwind CSS IntelliSense - Autocomplete para classes
- Prisma - Syntax highlighting para schemas
- AWS Toolkit - Ferramentas AWS integradas

> 💡 **Dica:** Aguarde a mensagem "Dev container ready" no terminal antes de continuar.

---

## 1.2 Configurar Credenciais AWS

O professor fornecerá as credenciais AWS. Configure-as no terminal do Codespaces:

### Comandos

```bash
export AWS_ACCESS_KEY_ID="sua-access-key-aqui"
export AWS_SECRET_ACCESS_KEY="sua-secret-key-aqui"
export AWS_DEFAULT_REGION="us-east-1"
```

> ⚠️ **Importante:** Substitua os valores acima pelas credenciais fornecidas pelo professor.

### Verificar Configuração

```bash
aws sts get-caller-identity
```

**Saída esperada:**

```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/workshop-student"
}
```

Se você ver informações sobre sua conta AWS, está tudo certo! ✅

### Em caso de problemas

**Erro: "Unable to locate credentials"**
- Verifique se copiou as credenciais corretamente
- Certifique-se de não ter espaços extras
- Execute os comandos `export` novamente

**Erro: "Invalid access key"**
- Verifique as credenciais com o professor
- Certifique-se de estar usando as credenciais corretas

---

## 1.3 Explorar a Estrutura do Projeto

### Árvore de Diretórios

```
serverless-webapp-starter-kit/
├── cdk/                    # 🏗️ Infraestrutura (AWS CDK)
│   ├── bin/
│   │   └── cdk.ts         # Ponto de entrada do CDK
│   ├── lib/
│   │   ├── main-stack.ts  # ⭐ Stack principal (IMPORTANTE!)
│   │   └── constructs/    # Componentes reutilizáveis
│   │       ├── database.ts
│   │       ├── auth/
│   │       ├── webapp.ts
│   │       ├── async-job.ts
│   │       └── event-bus/
│   ├── package.json
│   └── tsconfig.json
│
├── webapp/                 # 🌐 Aplicação Next.js
│   ├── src/
│   │   ├── app/           # Páginas e rotas
│   │   │   ├── (root)/    # Página principal
│   │   │   └── api/       # API routes
│   │   ├── components/    # Componentes React
│   │   ├── lib/           # Utilitários
│   │   └── middleware.ts  # Auth middleware
│   ├── prisma/
│   │   └── schema.prisma  # Schema do banco de dados
│   ├── package.json
│   └── Dockerfile
│
└── workshop/              # 📚 Documentação do workshop
    ├── README.md          # Você está aqui!
    └── ...
```

### Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `cdk/lib/main-stack.ts` | **Stack principal** - Define toda infraestrutura |
| `cdk/lib/constructs/` | Componentes AWS reutilizáveis |
| `webapp/src/app/(root)/page.tsx` | Página principal da aplicação |
| `webapp/src/app/(root)/actions.ts` | Server Actions (backend) |
| `webapp/prisma/schema.prisma` | Schema do banco de dados |

> 💡 **Dica:** Explore estes arquivos no VS Code para se familiarizar com o código.

---

## 1.4 Conceitos Fundamentais do AWS CDK

### O que é AWS CDK?

> 💡 **AWS Cloud Development Kit (CDK)**
>
> Permite definir infraestrutura em nuvem usando linguagens de programação como TypeScript. Em vez de escrever YAML ou JSON, você escreve código!

### Conceitos-chave

#### 1. Stack
**O que é?** Conjunto de recursos AWS que são implantados juntos.

**Exemplo:**
```typescript
export class MainStack extends Stack {
  constructor(scope: Construct, id: string, props: StackProps) {
    super(scope, id, props);

    // Todos os recursos aqui são deployados juntos
    const vpc = new Vpc(this, 'MyVpc');
    const database = new Database(this, 'MyDatabase', { vpc });
  }
}
```

#### 2. Construct
**O que é?** Componente reutilizável que representa um ou mais recursos AWS.

**Tipos:**
- **L1 Constructs**: Mapeamento 1:1 para CloudFormation
- **L2 Constructs**: Abstrações com defaults sensatos (mais usado)
- **L3 Constructs**: Padrões completos (ex: webapp inteira)

**Exemplo:**
```typescript
// L2 Construct - fácil e com defaults
const bucket = new Bucket(this, 'MyBucket', {
  encryption: BucketEncryption.S3_MANAGED,
  removalPolicy: RemovalPolicy.DESTROY
});
```

#### 3. Synthesize
**O que é?** Converter código CDK TypeScript em template CloudFormation.

**Comando:**
```bash
cdk synth
```

Gera template JSON/YAML que o CloudFormation entende.

#### 4. Deploy
**O que é?** Implantar os recursos definidos na AWS.

**Comando:**
```bash
cdk deploy
```

Cria todos os recursos no AWS CloudFormation.

### Comandos Principais do CDK

```bash
# Preparar conta AWS (executar apenas uma vez por conta)
cdk bootstrap

# Ver template CloudFormation gerado
cdk synth

# Ver diferenças antes de aplicar mudanças
cdk diff

# Implantar recursos na AWS
cdk deploy

# Implantar todas as stacks
cdk deploy --all

# Implantar sem pedir confirmação
cdk deploy --require-approval never

# Remover todos os recursos
cdk destroy

# Remover sem pedir confirmação
cdk destroy --force
```

### Fluxo de Trabalho CDK

```
1. Escrever código TypeScript
          ↓
2. cdk synth (gera CloudFormation)
          ↓
3. cdk diff (ver mudanças)
          ↓
4. cdk deploy (aplicar na AWS)
          ↓
5. Recursos criados no CloudFormation
```

---

## 1.5 Instalar Dependências

### No diretório CDK

```bash
cd cdk
npm ci
```

**O que `npm ci` faz?**
- Instala dependências exatamente como em `package-lock.json`
- Mais rápido que `npm install`
- Ideal para CI/CD e ambientes reproduzíveis

**Tempo estimado:** 1-2 minutos

### Verificar Instalação

```bash
# Verificar versão do CDK
npx cdk --version

# Deve mostrar algo como: 2.189.1 (build ...)
```

### Dependências Instaladas

As principais dependências incluem:

```json
{
  "aws-cdk-lib": "^2.189.1",     // CDK framework
  "constructs": "^10.0.0",        // Base para constructs
  "aws-cdk": "^2.1007.0",         // CLI do CDK
  "typescript": "^5.9.2"          // TypeScript compiler
}
```

---

## 1.6 Explorar o Código (Opcional)

Se você tem tempo extra, explore estes arquivos:

### 1. `cdk/bin/cdk.ts`

Ponto de entrada que define:
- Conta AWS a usar
- Regiões de deploy
- Propriedades do ambiente

```typescript
const app = new cdk.App();

const props: EnvironmentProps = {
  account: process.env.CDK_DEFAULT_ACCOUNT!,
  useNatInstance: true,  // Economiza $$$
};

// Cria stacks
new UsEast1Stack(app, 'ServerlessWebappStarterKitUsEast1Stack', {...});
new MainStack(app, 'ServerlessWebappStarterKitStack', {...});
```

### 2. `cdk/lib/main-stack.ts`

Stack principal que você vai modificar:

```typescript
export class MainStack extends Stack {
  constructor(scope: Construct, id: string, props: MainStackProps) {
    super(scope, id, props);

    // VPC
    const vpc = new Vpc(this, 'Vpc', {...});

    // Database
    const database = new Database(this, 'Database', { vpc });

    // Auth
    const auth = new Auth(this, 'Auth', {...});

    // ... outros recursos
  }
}
```

### 3. `webapp/prisma/schema.prisma`

Define schema do banco de dados:

```prisma
model User {
  id       String     @id
  TodoItem TodoItem[]
}

model TodoItem {
  id          String         @id @default(uuid())
  title       String
  description String         @db.Text()
  userId      String
  status      TodoItemStatus
  createdAt   DateTime       @default(now())
  updatedAt   DateTime       @updatedAt
  user        User           @relation(fields: [userId], references: [id])
}
```

---

## ✅ Verificação da Etapa

Antes de continuar, confirme que você completou:

- [x] GitHub Codespaces está rodando
- [x] Credenciais AWS configuradas e testadas
- [x] Estrutura do projeto explorada
- [x] Conceitos de CDK compreendidos
- [x] Dependências instaladas (`npm ci` executado)
- [x] `npx cdk --version` funciona

---

## 📚 Recursos Adicionais

- [Documentação AWS CDK](https://docs.aws.amazon.com/cdk/)
- [CDK Workshop](https://cdkworkshop.com/)
- [CDK API Reference](https://docs.aws.amazon.com/cdk/api/v2/)

---

## 🎉 Próxima Etapa

Parabéns! Seu ambiente está configurado e você entende os conceitos básicos.

**Agora vamos construir a infraestrutura!**

👉 **[Etapa 2: Deploy da Infraestrutura Base →](02-infrastructure.md)**

---

[← Voltar](README.md) | [Próximo: Infraestrutura →](02-infrastructure.md)

**Tempo desta etapa:** 15 minutos ⏱️
