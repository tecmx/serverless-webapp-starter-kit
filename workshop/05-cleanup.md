# Etapa 5: Exploração e Cleanup

[← Voltar](README.md) | [← Anterior: Features Avançadas](04-advanced-features.md)

---

## ⏱️ Tempo Estimado: 10 minutos

Nesta etapa final, você vai:
- 🔍 Explorar recursos no AWS Console
- 🧹 **IMPORTANTE:** Destruir recursos

---

## 5.1 Explorar Recursos no AWS Console

### CloudFormation

**URL:** https://console.aws.amazon.com/cloudformation

1. Acesse CloudFormation Console
2. Encontre stack: `ServerlessWebappStarterKitStack`
3. Explore as abas:

#### Tab: Resources
- **Veja:** ~50+ recursos criados
- Exemplos: Lambda functions, VPC, Aurora, Cognito, CloudFront
- Cada recurso tem link direto para seu console

#### Tab: Outputs
- **Veja:** Valores importantes exportados
- Exemplos: URLs, ARNs, comandos úteis
- Use para conectar serviços

#### Tab: Events
- **Veja:** Histórico de criação/atualização
- Timestamp de cada resource
- Erros (se houver)

#### Tab: Template
- **Veja:** CloudFormation JSON gerado pelo CDK
- Centenas de linhas de definição
- Compare com seu código TypeScript (muito mais simples!)

### Lambda Functions

**URL:** https://console.aws.amazon.com/lambda

1. Acesse Lambda Console
2. Encontre funções criadas:

**Functions do projeto:**
- `...-WebappHandler-...` - Aplicação Next.js
- `...-AsyncJobHandler-...` - Processador de jobs
- `...-MigrationRunner-...` - Database migrations
- `...-SignPayloadHandler-...` - Lambda@Edge

3. Clique em uma function, explore:
   - **Code**: Container Docker
   - **Configuration**: Memória, timeout, env vars
   - **Monitor**: Invocações, duração, erros
   - **Logs**: Link para CloudWatch

### RDS - Aurora Database

**URL:** https://console.aws.amazon.com/rds

1. Acesse RDS Console
2. Encontre cluster: `serverlesswebappstarterkitstack-databasecluster...`
3. Veja:
   - **Configuration**: PostgreSQL 16, Serverless v2
   - **Monitoring**: CPU, connections, IOPS
   - **Status**: Available / Sleeping (se auto-pause)
   - **Capacity**: Current ACUs

### Cognito

**URL:** https://console.aws.amazon.com/cognito

1. Acesse Cognito Console
2. User Pools → Encontre: `ServerlessWebappStarterKitStack-AuthUserPool...`
3. Explore:
   - **Users**: Sua conta criada!
   - **Groups**: (vazio neste projeto)
   - **App integration**: OAuth settings
   - **Sign-in experience**: Hosted UI config

### CloudFront

**URL:** https://console.aws.amazon.com/cloudfront

1. Acesse CloudFront Console
2. Encontre distribution da webapp
3. Veja:
   - **Domain name**: URL da aplicação
   - **Origins**: Lambda Function URL
   - **Behaviors**: Cache settings
   - **Invalidations**: Cache clears

### AppSync

**URL:** https://console.aws.amazon.com/appsync

1. Acesse AppSync Console
2. Encontre Event API criada
3. Veja:
   - **Schema**: Channel namespace
   - **Data sources**: (Event APIs não têm)
   - **Settings**: Auth config

### VPC

**URL:** https://console.aws.amazon.com/vpc

1. Acesse VPC Console
2. Encontre VPC criada
3. Explore:
   - **Subnets**: 4 subnets (2 public, 2 private)
   - **Route Tables**: Rotas para internet/NAT
   - **Internet Gateways**: Gateway da VPC
   - **NAT Instances** (EC2): t4g.nano rodando

---

## 5.3 Melhores Práticas Aprendidas

### ✅ Infrastructure as Code

**Benefícios:**
- Tudo versionado no Git
- Reproduzível em qualquer conta
- Code review em Pull Requests
- Rollback fácil se algo der errado
- Documentação viva (código = docs)

### ✅ Serverless

**Vantagens:**
- Zero manutenção de servidores
- Escala automática (0 a milhões)
- Alta disponibilidade por padrão
- Paga apenas pelo uso real
- Foco em código, não infra

**Trade-offs:**
- Cold starts (~1-3s)
- Limites de execução (15min Lambda)
- Vendor lock-in (AWS-specific)
- Debug mais complexo

### ✅ Type Safety

**End-to-end:**
- TypeScript no frontend
- TypeScript no backend
- Prisma para database (types gerados)
- Zod para validação
- **Resultado:** Menos bugs em produção!

### ✅ Segurança

**Implementado:**
- VPC isolada (recursos privados)
- Database em subnet privada
- Encryption at rest (Aurora)
- Encryption in transit (HTTPS)
- Cognito para auth (padrão OAuth)
- IAM roles com mínimo privilégio
- Security groups restritivos

### ✅ Observabilidade

**Incluído:**
- CloudWatch Logs automático
- Performance Insights (Aurora)
- Lambda metrics (invocações, erros, duração)
- CloudFront access logs
- X-Ray tracing (pode habilitar)

---

## 5.4 Próximos Passos (Após o Workshop)

### Features para Adicionar

**1. Categorias de TODO**
```prisma
model Category {
  id    String     @id
  name  String
  todos TodoItem[]
}
```

**2. Data de Vencimento**
```prisma
model TodoItem {
  dueDate DateTime?
  // ... outros campos
}
```

**3. Compartilhamento**
```prisma
model TodoItem {
  sharedWith String[]  // UserIDs
}
```

**4. Prioridades**
```prisma
enum Priority {
  LOW
  MEDIUM
  HIGH
}
```

### Melhorias de Infraestrutura

**1. Domínio Customizado**
```typescript
const hostedZone = HostedZone.fromLookup(this, 'Zone', {
  domainName: 'example.com'
});
// app.example.com
```

**2. CI/CD com GitHub Actions**
```yaml
# .github/workflows/deploy.yml
- name: CDK Deploy
  run: npx cdk deploy --require-approval never
```

**3. Múltiplos Ambientes**
```typescript
// dev, staging, prod
const envName = process.env.ENV_NAME;
```

**4. Testes Automatizados**
```typescript
// cdk/test/
test('VPC created', () => {
  const template = Template.fromStack(stack);
  template.hasResourceProperties('AWS::EC2::VPC', {...});
});
```

### Monitoramento Avançado

**1. Alarmes CloudWatch**
```typescript
const alarm = new Alarm(this, 'ErrorAlarm', {
  metric: lambda.metricErrors(),
  threshold: 10,
  evaluationPeriods: 2
});
```

**2. Dashboard**
```typescript
const dashboard = new Dashboard(this, 'Dashboard');
dashboard.addWidgets(
  new GraphWidget({ metrics: [lambda.metricInvocations()] })
);
```

**3. X-Ray Tracing**
```typescript
const lambda = new Function(this, 'Fn', {
  tracing: Tracing.ACTIVE
});
```

---

## 5.5 Limpeza dos Recursos

> ⚠️ **MUITO IMPORTANTE!**
>
> Destrua os recursos para evitar cobranças inesperadas!

### Comando de Destruição

```bash
cd cdk
npx cdk destroy --all --force
```

**Flags:**
- `--all`: Destrói todas as stacks
- `--force`: Não pede confirmação

**Tempo:** 10-15 minutos

### O Que Será Removido

- ✅ CloudFormation stacks (2)
- ✅ Lambda functions (4+)
- ✅ Aurora database (**dados serão perdidos!**)
- ✅ Cognito User Pool (**usuários serão perdidos!**)
- ✅ VPC e networking
- ✅ CloudFront distribution
- ✅ AppSync Event API
- ✅ S3 buckets (com auto-delete)
- ✅ CloudWatch log groups
- ✅ IAM roles criadas

### O Que NÃO Será Removido

- ⚠️ CDKToolkit stack (bootstrap) - **Deixe!** Não custa nada
- ⚠️ Alguns CloudWatch logs podem ficar
- ⚠️ Metrics no CloudWatch (retention padrão)

### Verificar Remoção

1. Acesse [CloudFormation Console](https://console.aws.amazon.com/cloudformation)
2. Verifique status das stacks:
   - `ServerlessWebappStarterKitStack` → `DELETE_COMPLETE`
   - `ServerlessWebappStarterKitUsEast1Stack` → `DELETE_COMPLETE`
3. Se houver `DELETE_FAILED`, veja erros e delete manualmente

### Cleanup Manual (Se Necessário)

**Se destroy falhar:**

```bash
# 1. Esvaziar buckets S3
aws s3 rm s3://BUCKET_NAME --recursive

# 2. Tentar destroy novamente
npx cdk destroy --all --force

# 3. Ou deletar via Console
# CloudFormation → Stack → Actions → Delete
```

### Confirmação Final

**Checklist:**
- [ ] `cdk destroy --all --force` executado
- [ ] Stacks mostram `DELETE_COMPLETE`
- [ ] VPC removida (EC2 Console)
- [ ] RDS cluster removido
- [ ] Lambda functions removidas
- [ ] CloudFront distribution deletada

---

## 🎓 Conclusão

### Parabéns! 🎉

Você completou o workshop e aprendeu:

#### Conceitos AWS
- ✅ Infrastructure as Code (AWS CDK)
- ✅ Serverless architecture
- ✅ VPC e networking
- ✅ Lambda functions & containers
- ✅ Aurora Serverless databases
- ✅ Cognito authentication
- ✅ CloudFront CDN
- ✅ AppSync Events (WebSockets)
- ✅ AI/ML services (Translate, Comprehend)
- ✅ EventBridge Scheduler
- ✅ CloudWatch monitoring

#### Práticas Modernas
- ✅ TypeScript full-stack
- ✅ Next.js App Router
- ✅ Server Actions
- ✅ Prisma ORM
- ✅ Database migrations
- ✅ Real-time communication
- ✅ Async job processing

#### Habilidades Práticas
- ✅ Deploy de apps completas
- ✅ Debugging com CloudWatch
- ✅ Cleanup de recursos

---

## 📚 Recursos para Continuar Aprendendo

### Documentação
- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### Tutoriais
- [AWS CDK Workshop](https://cdkworkshop.com/)
- [Serverless Land](https://serverlessland.com/)
- [AWS Samples GitHub](https://github.com/aws-samples)

### Certificações AWS
- **Cloud Practitioner** - Fundamentos
- **Solutions Architect Associate** - Arquitetura
- **Developer Associate** - Desenvolvimento

### Comunidades
- [AWS Community Builders](https://aws.amazon.com/developer/community/community-builders/)
- [Serverless Framework Discord](https://discord.gg/serverless)
- [CDK.dev Community](https://cdk.dev/)

---

## 📝 Feedback

Sua opinião é importante! Ajude a melhorar este workshop:

### O que funcionou bem?
- ...

### O que foi difícil?
- ...

### O que poderia melhorar?
- ...

### Conceitos que precisam mais explicação?
- ...

---

## 🎉 Obrigado!

Obrigado por participar deste workshop!

Esperamos que você tenha aprendido muito sobre AWS serverless e esteja pronto para construir suas próprias aplicações.

**Continue codando e explorando! 🚀**

---

[← Voltar ao Início](README.md) | [← Anterior: Features Avançadas](04-advanced-features.md)

**Tempo desta etapa:** 10 minutos ⏱️

**Workshop completo:** 90 minutos ✅
