
# Create a new VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true  # Enable DNS support
  enable_dns_hostnames = true  # Enable DNS hostnames


  tags = {
    Name = "remax-vpc"
  }
}

# Subnet within the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc-subnet-1"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-internet-gateway"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}



# Security Group for RabbitMQ
resource "aws_security_group" "rabbitmq_sg" {
  name        = "rabbitmq_sg"
  description = "Security group for RabbitMQ"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Replace with your IP address for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
