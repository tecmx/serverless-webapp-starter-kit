# GitHub Codespaces Configuration

Esta pasta contém a configuração para o GitHub Codespaces, otimizada para o workshop de AWS Serverless.

## O que está configurado

### Ferramentas Instaladas

- **Node.js 22**: Runtime JavaScript/TypeScript
- **AWS CLI**: Interface de linha de comando para AWS
- **Docker**: Para build de imagens Lambda
- **npm**: Gerenciador de pacotes

### Extensões VSCode

- **ESLint**: Linting de código
- **Prettier**: Formatação automática
- **Tailwind CSS IntelliSense**: Autocomplete para classes Tailwind
- **Prisma**: Syntax highlighting para arquivos .prisma
- **AWS Toolkit**: Ferramentas AWS integradas ao VSCode

### Configurações

- **Format on Save**: Código é formatado automaticamente ao salvar
- **ESLint Auto-fix**: Problemas de linting são corrigidos automaticamente
- **Prettier como formatador padrão**: Para todos os tipos de arquivo

### Post Create Command

Automaticamente executa `npm ci` nas pastas `cdk/` e `webapp/` após criar o Codespace.

### Portas Expostas

- **3000**: Next.js development server (padrão)
- **3010**: Next.js development server (workshop)

### Variáveis de Ambiente

- `AWS_PAGER=""`: Desabilita paginação do AWS CLI para melhor experiência no terminal

## Uso

Ao criar um novo Codespace:

1. Aguarde o provisionamento (2-3 minutos)
2. As dependências serão instaladas automaticamente
3. Configure suas credenciais AWS:
   ```bash
   export AWS_ACCESS_KEY_ID="..."
   export AWS_SECRET_ACCESS_KEY="..."
   export AWS_DEFAULT_REGION="us-east-1"
   ```
4. Siga as instruções do [WORKSHOP.md](../WORKSHOP.md)

## Troubleshooting

### Docker não está funcionando

Execute no terminal:
```bash
docker ps
```

Se falhar, aguarde alguns segundos e tente novamente (Docker pode estar iniciando).

### NPM install falhou

Execute manualmente:
```bash
cd cdk && npm ci
cd ../webapp && npm ci
```

### AWS CLI não encontrado

Reinicie o terminal ou execute:
```bash
source ~/.bashrc
```
