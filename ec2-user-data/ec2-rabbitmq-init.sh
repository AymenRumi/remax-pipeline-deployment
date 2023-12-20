#!/bin/bash


# Env Variables
export AWS_REGION=us-east-1
export AWS_SECRETS=remax-secrets
export IMAGE_TAG=latest

# Env variables through aws ecrets manager
export ECR_REGISTRY_FULL=$(aws secretsmanager get-secret-value --secret-id ${AWS_SECRETS} --query 'SecretString' --output text | jq -r '.repository_url')

export ECR_REGISTRY="${ECR_REGISTRY_FULL%/*}"
export IMAGE_NAME="${ECR_REGISTRY_FULL##*/}"


echo $ECR_REGISTRY
echo $IMAGE_NAME

# Update the installed packages and package cache
sudo yum update -y

# Install Docker
sudo yum install docker -y


# Start the Docker service
sudo service docker start

sudo groupadd docker

# Add the ec2-user to the docker group
sudo usermod -a -G docker ec2-user

# Docker permission
sudo chmod 666 /var/run/docker.sock

echo Logging into ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY


echo Pulling Docker Image
docker pull ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}


echo Running Docker Container
docker run --name my-rabbitmq-instance -d -p 5672:5672 -p 15672:15672 ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

