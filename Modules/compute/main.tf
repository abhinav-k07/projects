locals {
  my_name  = "${var.prefix}-${var.env}-compute"
  my_deployment   = "${var.prefix}-${var.env}"
}


# Elastic Load Balancer (elb) for our AWS Environment.

resource "aws_elb" "flaconi-elb" {
  name                       = "${local.my_name}-elb"
  internal                   = false
  security_groups            = ["${var.public-subnet-sg_id}"]
  subnets                    = ["${var.public_subnet_ids}"]
  


  listener {
    instance_port     = "${var.app_port}"
    instance_protocol = "http"
    lb_port           = "${var.elb_port}"
    lb_protocol       = "http"
  }

  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:${var.app_port}/"
    interval            = 30
  }

  
  tags = {
    Name        = "${local.my_name}-elb"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


# Launch Template and ASG Configuration for our Web Servers (EC2 Instances).


resource "aws_launch_template" "flaconi-lt" {
  name                    = "${local.my_name}"
  description             = "This Launch Template is used in Flaconi - Dev Environment"
  image_id                = "ami-098c5e80ad9341607"
  instance_type           = "t2.micro"
  disable_api_termination = false
  vpc_security_group_ids  = ["${var.private_subnet_sg_id}"]

  placement {
    availability_zone     = "${var.availability_zone}"
  }

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name        = "${local.my_name}-ec2"
      Deployment  = "${local.my_deployment}"
      Prefix      = "${var.prefix}"
      Environment = "${var.env}"
      Region      = "${var.region}"
      Terraform   = "true"
    }
  }
}

resource "aws_autoscaling_group" "flaconi-asg" {

  name                 = "${local.my_name}-asg"
  availability_zones   = ["${var.availability_zone}"]
  desired_capacity     = 2
  max_size             = 4
  min_size             = 1
  load_balancers       = ["${aws_elb.flaconi-elb.name}"]
  vpc_zone_identifier  = ["${var.private_subnet_ids}"]
  termination_policies = ["OldestInstance"]


  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances",
    "GroupTerminatingInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = "${aws_launch_template.flaconi-lt.id}"
    version = "$Latest"
  }

}

# Auto Scaling Policies for Scale Up EC2 Instances


resource "aws_autoscaling_policy" "flaconi-scale-up" {
  name                   = "${local.my_name}-autoscale-policy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.flaconi-asg.name}"
}



# CloudWatch Metric Alarms for corresponding metrics.

resource "aws_cloudwatch_metric_alarm" "memory-high" {

  alarm_name          = "${local.my_name}-flaconi-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric monitors ec2 memory for high utilization"

  
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.flaconi-asg.name}"
  }

  alarm_actions = [
    "${aws_autoscaling_policy.flaconi-scale-up.arn}"
  ]

}


# Auto Scaling Policies for Scale Down EC2 Instances

resource "aws_autoscaling_policy" "flaconi-scale-down" {
  name                   = "${local.my_name}-autoscale-policy-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.flaconi-asg.name}"
}


# CloudWatch Metric Alarms for corresponding metrics.

resource "aws_cloudwatch_metric_alarm" "memory-low" {
  alarm_name          = "${local.my_name}-flaconi-memory-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "This metric monitors ec2 memory for low utilization."


  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.flaconi-asg.name}"
  }

  alarm_actions = [
    "${aws_autoscaling_policy.flaconi-scale-down.arn}"
  ]

}
