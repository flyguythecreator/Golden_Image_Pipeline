resource "aws_placement_group" "test" {
  name     = "test"
  strategy = "cluster"
}

resource "aws_launch_template" "ansible_instance_launch_template" {
  name_prefix = "instances_launch_template-"
  image_id = "xyz"
  instance_type = "xyz"
  instance_initiated_shutdown_behavior = "stop"
  key_name = "${var.key_name}" 
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 40
      volume_type = "gp2"
      delete_on_termination = true
    }
  }
  ebs_optimized = true
  monitoring {
    enabled = true
  }
  user_data = "${base64encode(file("${path.module}/compute_startup_scripts/ansible_asg_startup_script.sh"))}"
}


# resource "aws_launch_template" "fooansible_asg" {
#   name_prefix   = "fooansible_asg"
#   image_id      = "ami-1a2b3c"
#   instance_type = "t2.micro"
# }

resource "aws_launch_template" "example2" {
  name_prefix = "example2"
  image_id    = data.aws_ami.example2.id
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc-example-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "ansible_instance_autoscaling_policy" {
  name                   = "ansible_instance_autoscaling_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ansible_asg.name
}

resource "aws_autoscaling_group" "ansible_asg" {
  name                      = "ansible_instance_autoscaling_group"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.test.id
  availability_zones = ["us-east-1a"]
  launch_template {
    id      = "${aws_launch_template.ansible_instance_launch_template.id}"
    version = "$Latest"
  }
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.example1.id, aws_subnet.example2.id]

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  initial_lifecycle_hook {
    name                 = "foobar"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = jsonencode({
      foo = "ansible_asg"
    })

    notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }
  tag {
    key                 = "lorem"
    value               = "ipsum"
    propagate_at_launch = false
  }
  dynamic "tag" {
    for_each = var.extra_tags
    content {
      key                 = tag.value.key
      propagate_at_launch = tag.value.propagate_at_launch
      value               = tag.value.value
    }
  }
}