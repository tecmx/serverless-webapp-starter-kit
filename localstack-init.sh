#!/bin/bash
set -e

echo "🚀 Inicializando LocalStack..."

# Aguarda o LocalStack estar pronto
echo "⏳ Aguardando LocalStack estar pronto..."
until curl -s http://localhost:4566/_localstack/health | grep -q '"s3": "available"'; do
  echo "   Aguardando serviços LocalStack..."
  sleep 2
done

echo "✅ LocalStack está pronto!"

# Configura credenciais AWS locais
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-west-2

# Define o endpoint do LocalStack
export AWS_ENDPOINT_URL=http://localhost:4566

echo "📦 Configurando ambiente local..."

# Verifica se o postgres está rodando
echo "🐘 Verificando PostgreSQL..."
DOCKER_COMPOSE_CMD=$(which docker-compose 2>/dev/null || echo "docker compose")
until $DOCKER_COMPOSE_CMD exec -T postgres pg_isready -U root > /dev/null 2>&1; do
  echo "   Aguardando PostgreSQL..."
  sleep 2
done

echo "✅ PostgreSQL está pronto!"

echo ""
echo "🎉 Ambiente LocalStack configurado com sucesso!"
echo ""
echo "📋 Próximos passos:"
echo "   1. Configure suas credenciais:"
echo "      export AWS_ACCESS_KEY_ID=test"
echo "      export AWS_SECRET_ACCESS_KEY=test"
echo "      export AWS_DEFAULT_REGION=us-west-2"
echo "      export AWS_ENDPOINT_URL=http://localhost:4566"
echo ""
echo "   2. Faça o deploy:"
echo "      cd cdk"
echo "      npm run deploy:local"
echo ""
