#!/bin/bash
# awslocal.sh - Wrapper para AWS CLI com LocalStack
# Uso: ./awslocal.sh s3 ls
#      ./awslocal.sh lambda list-functions

# Configurações LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-west-2
export AWS_ENDPOINT_URL=http://localhost:4566

# Executa comando AWS CLI
aws "$@"
