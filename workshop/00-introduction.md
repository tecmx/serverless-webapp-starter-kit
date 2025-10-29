# Introdução ao Workshop

[← Voltar ao Índice](README.md)

---

## 📋 Visão Geral

Bem-vindo ao workshop prático de desenvolvimento e deployment de uma aplicação web serverless completa na AWS!

Neste workshop de 90 minutos, você aprenderá a implantar uma aplicação de lista de tarefas (todo list) moderna usando Infrastructure as Code (IaC) com AWS CDK.

**Importante:** Não será usado o Console da AWS para criar recursos - tudo será feito via código!

---

## 🎯 Objetivos de Aprendizagem

Ao final deste workshop, você será capaz de:

1. ✅ Configurar e usar AWS CDK para Infrastructure as Code
2. ✅ Implantar aplicações serverless na AWS de forma incremental
3. ✅ Entender arquitetura de aplicações full-stack modernas
4. ✅ Trabalhar com serviços AWS essenciais:
   - Lambda (computação serverless)
   - Aurora Serverless (banco de dados)
   - Cognito (autenticação)
   - CloudFront (CDN global)
   - AppSync Events (real-time)
5. ✅ Implementar autenticação segura
6. ✅ Criar comunicação em tempo real com WebSockets
7. ✅ Fazer cleanup apropriado de recursos

---

## 🏗️ Arquitetura

Aqui está a arquitetura completa que você vai construir:

![Arquitetura](../imgs/architecture.png)

### Componentes Principais

```
┌─────────────────────────────────────────────────────────────┐
│                         Usuário                             │
└──────────────┬──────────────────────────────────────────────┘
               │
               ├─── HTTPS ────→ CloudFront (CDN Global)
               │                    │
               │                    ↓
               │               Lambda@Edge (Validação)
               │                    │
               │                    ↓
               │             Next.js Lambda ────────┐
               │                    │               │
               │                    ├──────────→ Aurora
               │                    │            PostgreSQL
               │                    │
               │                    ├──────────→ Cognito
               │                    │            (Auth)
               │                    │
               │                    └──────────→ AppSync
               │                                 Events
               │
               └─ WebSocket ──→ AppSync Events
                                     ↑
                                     │
                              AsyncJob Lambda
                                     │
                              ┌──────┴──────┐
                         Translate    Comprehend
```

---

## 📦 O Que Você Vai Construir

### Aplicação: Lista de Tarefas (TODO App)

Uma aplicação web completa e funcional com:

#### Frontend
- Interface moderna e responsiva
- React 19 + Next.js 15
- Tailwind CSS para estilização
- Autenticação integrada
- Atualizações em tempo real

#### Backend
- Next.js Server Actions
- Type-safe end-to-end
- Prisma ORM para database
- Validação com Zod
- Jobs assíncronos

#### Infraestrutura
- Tudo definido como código (IaC)
- Deploy com um único comando
- Escalabilidade automática
- Alta disponibilidade

---

## 🛠️ Tecnologias que Você Vai Usar

### Serviços AWS (12)

| Serviço | Uso |
|---------|-----|
| **AWS Lambda** | Executar aplicação Next.js serverless |
| **Lambda@Edge** | Validação e segurança no edge |
| **Aurora Serverless v2** | Banco de dados PostgreSQL |
| **Amazon Cognito** | Autenticação de usuários |
| **CloudFront** | CDN global para distribuição |
| **VPC** | Rede virtual isolada |
| **AppSync Events** | Real-time WebSockets |
| **Amazon Translate** | Tradução automática |
| **Comprehend** | Detecção de idioma |
| **CloudWatch** | Logs e monitoramento |
| **S3** | Armazenamento de assets |
| **CloudFormation** | Orquestração de recursos |

### Stack de Desenvolvimento (8)

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| **TypeScript** | 5.x | Linguagem type-safe |
| **React** | 19 | Framework frontend |
| **Next.js** | 15 | Full-stack framework |
| **Prisma** | 6.x | ORM para database |
| **Tailwind CSS** | 4.x | Estilização |
| **Zod** | 3.x | Validação de schemas |
| **AWS CDK** | 2.x | Infrastructure as Code |
| **Docker** | latest | Containerização |

---

## ⚠️ Avisos Importantes

### ✅ Fazer

- ✅ Seguir instruções em ordem
- ✅ Ler conceitos explicados
- ✅ Testar cada etapa
- ✅ Perguntar quando tiver dúvidas
- ✅ **DESTRUIR recursos no final** (`cdk destroy`)

### ❌ Não Fazer

- ❌ Pular etapas
- ❌ Modificar código sem entender
- ❌ Compartilhar credenciais AWS
- ❌ **Esquecer de fazer cleanup**
- ❌ Usar região diferente da especificada

---

## 📚 Estrutura da Documentação

Este workshop está organizado em:

### Etapas Principais
1. [Setup (15 min)](01-setup.md)
2. [Infraestrutura (25 min)](02-infrastructure.md)
3. [Aplicação (25 min)](03-application.md)
4. [Features Avançadas (15 min)](04-advanced-features.md)
5. [Cleanup (10 min)](05-cleanup.md)

### Recursos Auxiliares
- [Quick Reference](quick-reference.md) - Comandos essenciais

---

## 🚀 Próximos Passos

Agora que você entende o que vai construir, vamos começar!

### Pronto?

👉 **[Vá para Etapa 1: Setup →](01-setup.md)**

---

[← Voltar ao Índice](README.md) | [Próximo: Setup →](01-setup.md)

**Tempo estimado de leitura:** 5 minutos
