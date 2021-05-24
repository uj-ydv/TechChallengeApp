data "aws_availability_zones" "available"{}

# # Define AMI
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners = ["099720109477"]
#   filter {
#     name = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
#   }
# }

resource "aws_key_pair" "my_aws_key" {
    key_name = "servianKeyPair"
    public_key = (file(var.PATH_TO_PUBLIC_KEY))
}

# define autoscaling launch configuration
resource "aws_launch_configuration" "custom_launch_config" {
  name = "custom_launch_config"
  image_id = "ami-0567f647e75c7bc05"
  instance_type = "t2.micro"
  key_name = aws_key_pair.my_aws_key.key_name
  security_groups = [aws_security_group.custom-instance-sg.id]
  # Installing dependencies in the instance and running Application server
  user_data = "#!/bin/bash\nsudo su\nsudo apt-get -y update\nsudo apt install -y golang\nmkdir servian\ncd servian\nsudo git clone https://github.com/uj-ydv/TechChallengeApp.git\ncd TechChallengeApp\nchmod 777 build.sh\nsudo ./build.sh\ncd dist\nsudo ./TechChallengeApp updatedb\nsudo ./TechChallengeApp serve"

  lifecycle {
      create_before_destroy = true
  }
}

#define autoscaling group
resource "aws_autoscaling_group" "custom-group-autoscaling" {
  name                      = "fcustom-group-autoscaling"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 100
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.custom_launch_config.name
  vpc_zone_identifier       = [aws_subnet.customvpc-public-2.id, aws_subnet.customvpc-public-1.id] #default subnet
  tag {
    key                 = "Name"
    value               = "custom_ec2_instance"
    propagate_at_launch = true
  }
}

#define autoscaling configuration policy
resource "aws_autoscaling_policy" "custom-cpu-policy" {
    name = "custom-cpu-policy"
    autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = 1
    cooldown = 300
    policy_type = "SimpleScaling" 
}

# define cloudwatch monitoring
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm" {
  alarm_name = "custom-cpu-alarm"
  alarm_description = "Alarm once cpu usage increase"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 20

  dimensions = {
    "AutoScalingGroupName" = "aws_autoscaling_group.custom-group-autoscaling.name"
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.custom-cpu-policy.arn]
}

# Define auto descaling policy
resource "aws_autoscaling_policy" "custom-cpu-policy-scaledown" {
  name = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.custom-group-autoscaling.name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = -1
  cooldown = 300
  policy_type = "SimpleScaling"
}

# Define Descaling cloud watch
resource "aws_cloudwatch_metric_alarm" "custom-cpu-alarm-scaledown" {
  alarm_name = "custom-cpu-alarm-scaledown"
  alarm_description = "Alarm once cpu usage decreases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = 10

  dimensions = {
    "AutoScalingGroupName" = "aws_autoscaling_group.custom-group-autoscaling.name"
  }
  actions_enabled = true
  alarm_actions = [aws_autoscaling_policy.custom-cpu-policy-scaledown.arn]
}