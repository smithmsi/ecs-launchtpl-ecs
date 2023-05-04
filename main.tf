provider "aws" {
  region = "us-east-2"
}

resource "aws_launch_template" "test" {
  name                   = var.lauch_template_name
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = filebase64("${path.module}/script.sh")
  vpc_security_group_ids = [var.sg_id]


  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
 

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
}

resource "aws_autoscaling_group" "testasg" {

  name                      = var.autoscaling_group_name
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = [var.subnet_id]
  health_check_grace_period = 300
  #health_check_type         = var.asg_health_check_type #"ELB" or default EC2
  #availability_zones = var.availability_zones #["us-east-1a"]
  #vpc_zone_identifier = var.lb_subnets
  #target_group_arns   = [module.aws_lb.lb_tg_arn] #var.target_group_arns

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  #metrics_granularity = "1Minute"
  #tags = {
  #  Name        = "example-asg"
  #  Environment = "dev"
  #
  #  }


  launch_template {
    id      = aws_launch_template.test.id
    version = aws_launch_template.test.latest_version #"$Latest"
  }
  #depends_on = [module.aws_lb]
}


# scale up policy
resource "aws_autoscaling_policy" "testasg" {
  name                   = var.autoscaling_policy_name
  autoscaling_group_name = var.autoscaling_group_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"

  depends_on = [
    aws_autoscaling_group.testasg
  ]
}


# Create the ECS cluster
resource "aws_ecs_cluster" "test" {
  name = var.cluster_name
}