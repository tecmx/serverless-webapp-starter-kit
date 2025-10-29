# Etapa 4: Recursos Avançados

[← Voltar](README.md) | [← Anterior: Aplicação](03-application.md) | [Próximo: Cleanup →](05-cleanup.md)

---

## ⏱️ Tempo Estimado: 15 minutos

Nesta etapa, você vai explorar recursos avançados:
- 🌍 Jobs assíncronos com Amazon Translate
- ⚡ Notificações em tempo real via WebSockets
- 🔄 Comunicação bidirecional

---

## 4.1 Entender o EventBus

### O Que É?

Sistema de comunicação em tempo real usando WebSockets (AppSync Events).

### Como Funciona?

```
Frontend (Browser)
     ↓
  WebSocket
     ↓
AppSync Events API
     ↑
  Publish
     ↑
Lambda (AsyncJob)
```

**Frontend subscreve:** `user/{userId}/jobs`
**Backend publica:** Eventos quando jobs terminam
**Frontend recebe:** Atualização automática

### Código Frontend

```typescript
// hooks/use-event-bus.ts
useEventBus({
  channelName: `user/${userId}/jobs`,
  onReceived: (data) => {
    console.log('Job completed!', data);
    router.refresh(); // Atualiza página
  },
});
```

### Código Backend

```typescript
// Publica evento quando job termina
await publishEvent({
  channel: `user/${userId}/jobs`,
  event: {
    type: 'translate_completed',
    todoId: todo.id
  }
});
```

**Leia mais:** [concepts/appsync.md](concepts/appsync.md)

---

## 4.2 Entender Jobs Assíncronos

### Por Que Assíncrono?

**Síncrono (bloqueante):**
```
User → [esperando 10s...] → Resposta
❌ UI travada
❌ Timeout possível
❌ Má experiência
```

**Assíncrono (não-bloqueante):**
```
User → Resposta imediata: "Processing..."
         ↓
     [Job processa em background]
         ↓
     WebSocket notifica: "Done!"
         ↓
     UI atualiza automaticamente
✅ UI responsiva
✅ Sem timeout
✅ Ótima experiência
```

### Nossa Implementação

**Trigger:**
```typescript
// Server Action
export const runTranslateJob = authActionClient
  .schema(runTranslateJobSchema)
  .action(async ({ parsedInput, ctx }) => {
    // Invoca Lambda assíncrono
    await runJob({
      type: 'translate',
      todoItemId: parsedInput.id,
      userId: ctx.userId
    });
    // Retorna imediatamente!
  });
```

**Processamento:**
```typescript
// AsyncJob Lambda
async function handleTranslateJob(payload) {
  // 1. Buscar TODO
  const todo = await prisma.todoItem.findUnique({...});

  // 2. Detectar idioma (Comprehend)
  const language = await detectLanguage(todo.title);

  // 3. Traduzir (Translate)
  const translated = await translate(todo.title, language, 'en');

  // 4. Atualizar no banco
  await prisma.todoItem.update({
    where: { id: todo.id },
    data: { title: translated }
  });

  // 5. Notificar via EventBus
  await publishEvent({
    channel: `user/${userId}/jobs`,
    event: { type: 'translate_completed' }
  });
}
```

---

## 4.3 Testar Tradução Assíncrona

### Criar TODO em Português

1. Na aplicação, clique em **+ Add New Todo**
2. Preencha:
   - **Title**: `Estudar para prova de matemática`
   - **Description**: `Revisar álgebra e geometria`
3. Clique em **Create Todo**

### Abrir Console do Navegador

1. Pressione **F12** (ou **Cmd+Option+I** no Mac)
2. Vá para a aba **Console**
3. Deixe aberto para ver eventos

### Executar Tradução

1. Encontre o TODO que você criou
2. Clique no botão **Translate** (ícone de globo 🌍)
3. Observe o console do navegador

**O que você verá no console:**
```
Job started: translate
[após alguns segundos...]
received {type: 'translate_completed', todoId: '...'}
```

### Resultado

Após 5-15 segundos:
- ✅ Página atualiza automaticamente
- ✅ TODO agora está em inglês!
- ✅ `"Estudar para prova de matemática"` → `"Study for math test"`

---

## 4.4 Entender o Fluxo Completo

### Passo a Passo

```
1. Usuário clica "Translate" 🌍
         ↓
2. Frontend chama runTranslateJob()
         ↓
3. Server Action invoca AsyncJob Lambda
         ↓
4. Lambda processa em background:
   a. Busca TODO no Aurora
   b. Detecta idioma (Comprehend)
      - "Estudar..." → pt (português)
   c. Traduz texto (Translate)
      - pt → en: "Study..."
   d. Atualiza TODO no Aurora
   e. Publica evento no EventBus
         ↓
5. Frontend recebe evento via WebSocket
         ↓
6. Frontend chama router.refresh()
         ↓
7. Next.js re-fetcha dados do servidor
         ↓
8. UI re-renderiza com TODO traduzido ✅
```

### Timing

- **Invoke Lambda**: ~100-200ms
- **Cold start** (se dormindo): ~2-3s
- **Warm Lambda**: ~100ms
- **Detectar idioma**: ~500ms
- **Traduzir**: ~500-1000ms
- **Update database**: ~100ms
- **Publish event**: ~100ms
- **WebSocket delivery**: ~100-200ms
- **Total**: ~5-15 segundos

---

## 4.5 Serviços AI da AWS

### Amazon Comprehend

**O que faz?** Detecta idioma, sentimento, entidades, etc.

**Nossa uso:**
```typescript
const result = await comprehend.detectDominantLanguage({
  Text: "Estudar para prova"
});
// result.Languages[0].LanguageCode = "pt"
```

**Idiomas suportados:** 100+ incluindo português, espanhol, inglês, etc.

### Amazon Translate

**O que faz?** Traduz texto entre idiomas.

**Nossa uso:**
```typescript
const result = await translate.translateText({
  Text: "Estudar para prova",
  SourceLanguageCode: "pt",
  TargetLanguageCode: "en"
});
// result.TranslatedText = "Study for test"
```

**Idiomas:** 75+ pares de idiomas

**Qualidade:**
- Neural Machine Translation (NMT)
- Alta precisão
- Contexto preservado
- Formatação mantida

---

## 4.6 Explorar Eventos no Console

### Ver Conexões WebSocket

**No Console do Navegador (F12):**

1. Vá para aba **Network**
2. Filtro: **WS** (WebSockets)
3. Encontre conexão ao AppSync
4. Veja mensagens trocadas

**Mensagens:**
- `start_subscription` - Inscrição no canal
- `data` - Eventos recebidos
- `ka` - Keep-alive (ping/pong)

### Ver Logs do Lambda

1. Acesse [CloudWatch Console](https://console.aws.amazon.com/cloudwatch)
2. Logs → Log groups
3. `/aws/lambda/...-AsyncJobHandler...`
4. Veja execuções do job

**O que você verá:**
```
START RequestId: abc123...
Processing translate job for todo: xyz...
Detected language: pt
Translating pt -> en
Updated todo
Published event to EventBus
END RequestId: abc123...
REPORT Duration: 2341.23 ms Memory: 156/256 MB
```

---

## 4.7 Outros Use Cases de Jobs Assíncronos

### Exemplos no Mundo Real

**1. Processamento de Imagem**
```
Upload → Resize → Thumbnail → OCR → S3
```

**2. Envio de Email em Massa**
```
Trigger → Queue → Lambda → SES → Emails
```

**3. Geração de Relatório**
```
Request → Query DB → Generate PDF → Upload → Notify
```

**4. Pipeline de Dados**
```
Ingest → Transform → Enrich → Load → Analytics
```

### Alternativas no Ecossistema AWS

| Serviço | Uso | Quando Usar |
|---------|-----|-------------|
| **Lambda Async** | Nossa abordagem | Simples, baixo volume |
| **SQS + Lambda** | Fila + consumidor | Alto volume, retry |
| **Step Functions** | Workflows complexos | Múltiplos steps, condicionais |
| **EventBridge** | Event-driven | Múltiplos consumers |
| **Fargate** | Container longo | Jobs >15min |

---

## 4.8 Scheduled Jobs (Bonus)

O projeto já inclui um exemplo de job agendado!

**Código:**
```typescript
// AsyncJob construct
this.addSchedule(
  'SampleJob',
  ScheduleExpression.cron({
    minute: '0',
    hour: '0',
    day: '1',
    timeZone: TimeZone.ETC_UTC
  })
);
```

**Executa:** Todo dia 1 do mês às 00:00 UTC

**Use cases:**
- Limpeza de dados antigos
- Relatórios mensais
- Backups agendados
- Notificações recorrentes

---

## 📊 Resumo da Etapa

### O Que Você Testou

- ✅ Job assíncrono (tradução)
- ✅ Amazon Comprehend (detecção de idioma)
- ✅ Amazon Translate (tradução)
- ✅ AppSync Events (WebSocket)
- ✅ Notificações em tempo real
- ✅ Atualização automática de UI

### Conceitos Aprendidos

- ✅ Comunicação assíncrona
- ✅ WebSockets vs HTTP
- ✅ Event-driven architecture
- ✅ AI/ML services da AWS
- ✅ Lambda invocação assíncrona

---

## 🎉 Próxima Etapa

Incrível! Você explorou recursos avançados de uma aplicação serverless moderna.

**Agora vamos fazer cleanup dos recursos!**

👉 **[Etapa 5: Exploração e Cleanup →](05-cleanup.md)**

---

[← Voltar](README.md) | [← Anterior: Aplicação](03-application.md) | [Próximo: Cleanup →](05-cleanup.md)

**Tempo desta etapa:** 15 minutos ⏱️
