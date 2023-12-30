
resource "aws_autoscaling_group" "asg" {
  name = "celery-worker-autoscaling" 
  max_size             = 10
  min_size             = 0
  vpc_zone_identifier  = [aws_subnet.my_subnet.id]

  launch_template {
    id      = aws_launch_template.celery-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Autoscaling Group"
    value               = "my-asg-ec2-instance"
    propagate_at_launch = true
  }
}
    
