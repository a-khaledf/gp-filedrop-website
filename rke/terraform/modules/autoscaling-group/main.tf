
resource "aws_autoscaling_group" "autoscaling_group" {
  name = var.name

  launch_configuration = aws_launch_configuration.launch_configuration.name
  vpc_zone_identifier  = [var.public_subnet_id]

  min_size         = 3
  max_size         = 3
  desired_capacity = 3

  termination_policies = ["OldestInstance", "OldestLaunchConfiguration"]

  health_check_grace_period = 5

  health_check_type = "EC2"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix = var.name

  image_id      = var.instance_image_id
  instance_type = var.instance_type

  user_data                   = file("user_data.sh")
  key_name                    = var.key_pair_name
  security_groups             = [var.security_group_id]
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
