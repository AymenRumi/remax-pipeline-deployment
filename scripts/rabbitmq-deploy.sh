export AWS_SECRETS=remax-pipeline-secrets
export IMAGE_NAME=rabbitmq
export ECR_REGISTRY=$(aws secretsmanager get-secret-value --secret-id ${AWS_SECRETS} --query 'SecretString' --output text | jq -r '.repository_url')






