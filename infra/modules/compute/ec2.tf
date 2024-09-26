resource "aws_launch_template" "ansible_instance_launch_template" {
  name_prefix = "instances_launch_template-"
  instance_type = "${var.instance_type}"
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


# Our master instance with everything we need to use ansible
resource "aws_instance" "master" {
    launch_template {
      id = aws_launch_template.ansible_instance_launch_template.id
      name = "AnsibleComputeNode"
    }
    instance_type = "${var.instance_type}"
}
