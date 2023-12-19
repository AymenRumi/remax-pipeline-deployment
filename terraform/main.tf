provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "ecr_repo" {
  name = "rabbitmq"  # Replace with your desired repository name
}


resource "aws_secretsmanager_secret" "my_secrets" {
  name        = "remax-pipeline-secrets"
  description = "Environment variables for pipeline deployment"
}


resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.my_secrets.id
  secret_string = jsonencode({
   repository_url = aws_ecr_repository.ecr_repo.repository_url 
  })
}


# # Create a new VPC
# resource "aws_vpc" "my_vpc" {
#   cidr_block = "10.0.0.0/16"

#   enable_dns_support   = true  # Enable DNS support
#   enable_dns_hostnames = true  # Enable DNS hostnames


#   tags = {
#     Name = "remax-vpc"
#   }
# }

# # Subnet within the VPC
# resource "aws_subnet" "my_subnet" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone = "us-east-1a"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "vpc-subnet-1"
#   }
# }


# resource "aws_internet_gateway" "gw" {
#   vpc_id = aws_vpc.my_vpc.id

#   tags = {
#     Name = "my-internet-gateway"
#   }
# }


# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name = "public-route-table"
#   }
# }

# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.my_subnet.id
#   route_table_id = aws_route_table.public_route_table.id
# }


# # ECS Cluster
# resource "aws_ecs_cluster" "rabbitmq_cluster" {
#   name = "rabbitmq-cluster"
# }

# # Instance for RabbitMQ
# resource "aws_instance" "rabbitmq_instance" {
#   ami                    = "ami-079db87dc4c10ac91"  # Replace with a valid AMI ID
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.my_subnet.id
#   vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]
#   key_name = "chrome-test"

#   tags = {
#     Name = "rabbitmq-instance"
#   }
# }



# # IAM Role for ECS Execution
# resource "aws_iam_role" "ecs_execution_role" {
#   name = "rabbitmq_ecs_execution_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         },
#       },
#     ],
#   })
# }



# # Security Group for RabbitMQ
# resource "aws_security_group" "rabbitmq_sg" {
#   name        = "rabbitmq_sg"
#   description = "Security group for RabbitMQ ECS"
#   vpc_id      = aws_vpc.my_vpc.id

#   ingress {
#     from_port   = 5672
#     to_port     = 5672
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 15672
#     to_port     = 15672
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  // Replace with your IP address for security
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # # ECS Task Definition for RabbitMQ
# # resource "aws_ecs_task_definition" "rabbitmq" {
# #   family                   = "rabbitmq"
# #   network_mode             = "awsvpc"
# #   requires_compatibilities = ["EC2"]
# #   cpu                      = "256"
# #   memory                   = "512"
# #   execution_role_arn       = aws_iam_role.ecs_execution_role.arn
# #   container_definitions  = file("${path.module}/task-definitions/rabbitmq.json")

# # }


# # # ECS Service for RabbitMQ
# # resource "aws_ecs_service" "rabbitmq_service" {
# #   name            = "rabbitmq-service"
# #   cluster         = aws_ecs_cluster.rabbitmq_cluster.id
# #   task_definition = aws_ecs_task_definition.rabbitmq.arn
# #   launch_type     = "FARGATE"  # Use "FARGATE" or "EC2" based on your preference

# #   network_configuration {
# #     subnets = [aws_subnet.my_subnet.id]
# #     security_groups = [aws_security_group.rabbitmq_sg.id]
# #   }

# #   desired_count = 1

# #   # Additional configurations as necessary...
# # }

# # output "rabbitmq_config" {
# #   value = file("${path.module}/task-definitions/rabbitmq.json")
# # }