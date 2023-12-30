
resource "aws_secretsmanager_secret" "my_secrets" {
  name        = "remax-secrets"
  description = "Environment variables for pipeline deployment"
}


resource "aws_secretsmanager_secret_version" "secrets" {
  secret_id     = aws_secretsmanager_secret.my_secrets.id
  secret_string = jsonencode({
   repository_url = aws_ecr_repository.ecr_repo.repository_url
   rabbitmq_host = aws_instance.rabbitmq_instance.public_dns
   rabbitmq_username = var.rabbitmq_username
   rabbitmq_password =  var.rabbitmq_password
   rabbitmq_broker_url = format("amqp://%s:%s@%s",var.rabbitmq_username, var.rabbitmq_password,aws_instance.rabbitmq_instance.public_dns)
   celery_autoscaling_group = aws_autoscaling_group.asg.name
  })
}
