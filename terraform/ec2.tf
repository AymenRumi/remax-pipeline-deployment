
# Instance for RabbitMQ
resource "aws_instance" "rabbitmq_instance" {
  ami                    = "ami-079db87dc4c10ac91"  
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]
  key_name = "chrome-test"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = file("${path.module}/../ec2-user-data/ec2-rabbitmq-init.sh")


  tags = {
    Name = "rabbitmq-instance"
  }
}

