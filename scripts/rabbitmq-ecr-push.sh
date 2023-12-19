#!/bin/bash

# ENV Variables
export AWS_REGION=us-east-1
export AWS_SECRETS=remax-secrets

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' 




# Reading ENV Variables from AWS Secrets Manager
export RABBITMQ_USER=$(aws secretsmanager get-secret-value --secret-id ${AWS_SECRETS} --query 'SecretString' --output text | jq -r '.rabbitmq_username')
export RABBITMQ_PASS=$(aws secretsmanager get-secret-value --secret-id ${AWS_SECRETS} --query 'SecretString' --output text | jq -r '.rabbitmq_password')

export ECR_REGISTRY_FULL=$(aws secretsmanager get-secret-value --secret-id ${AWS_SECRETS} --query 'SecretString' --output text | jq -r '.repository_url')

export ECR_REGISTRY="${ECR_REGISTRY_FULL%/*}"
export IMAGE_NAME="${ECR_REGISTRY_FULL##*/}"


# Building RabbitMQ Docker Image
echo "${GREEN}Building Docker Image Image${NC}"
docker build --platform linux/amd64 --build-arg RABBITMQ_USER=$RABBITMQ_USER --build-arg RABBITMQ_PASSWORD=$RABBITMQ_PASS --no-cache -t $IMAGE_NAME -f Dockerfile.RabbitMQ .


echo "${GREEN}Tagging Image${NC}"
docker tag $IMAGE_NAME:latest ${ECR_REGISTRY}/${IMAGE_NAME}:latest

# Logging in to ECR registry
echo "${GREEN}Logging in to ECR registry${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Pushing Image
echo "${GREEN}Pushing Image${NC}"
docker push ${ECR_REGISTRY}/${IMAGE_NAME}:latest

