#!/bin/bash
# cleanup.sh - Script para limpar ambiente de desenvolvimento

set -e

echo "🧹 Iniciando limpeza do ambiente..."

# Para e remove containers Docker
if [ -f "compose.yaml" ]; then
    echo "🐳 Parando containers Docker..."
    docker compose down -v 2>/dev/null || true
fi

# Remove volume do LocalStack (requer sudo)
if [ -d "volume" ]; then
    echo "📦 Removendo volume do LocalStack..."
    sudo rm -rf volume/ 2>/dev/null || rm -rf volume/ 2>/dev/null || true
fi

# Limpa node_modules do CDK
if [ -d "cdk/node_modules" ]; then
    echo "📦 Limpando node_modules do CDK..."
    rm -rf cdk/node_modules
fi

# Limpa cdk.out
if [ -d "cdk/cdk.out" ]; then
    echo "📦 Limpando cdk.out..."
    rm -rf cdk/cdk.out
fi

# Limpa node_modules da webapp
if [ -d "webapp/node_modules" ]; then
    echo "📦 Limpando node_modules da webapp..."
    rm -rf webapp/node_modules
fi

# Remove arquivos de ambiente local
echo "🔐 Removendo arquivos de ambiente local..."
rm -f localstack.env .env.localstack 2>/dev/null || true
rm -f docker-compose.override.yml 2>/dev/null || true

echo ""
echo "✅ Limpeza concluída!"
echo ""
echo "Para reiniciar o ambiente:"
echo "  make setup    # Reinstala dependências"
echo "  make init     # Inicia LocalStack"
echo "  make deploy   # Deploy local"
