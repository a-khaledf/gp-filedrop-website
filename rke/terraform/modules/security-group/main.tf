resource "aws_security_group" "security_group" {
  name        = var.name
  description = "The security group for ${var.name}."

  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all_outbound" {
  description = "allow all outbound communications from the cluster nodes to the internet"

  # allow all outbound calls from any port with any protocol to any ip address
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.security_group.id
}

# Allow ssh into the cluster nodes from specific IP ranges
resource "aws_security_group_rule" "allow_ssh_inbound" {
  description = "allow ssh into the nodes from anywhere"

  # allow ssh into the nodes from specific CIDR blocks
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "allow_ssh_inbound_k8s" {
  description = "allow ssh into the nodes from anywhere"

  # allow ssh into the nodes from specific CIDR blocks
  type        = "ingress"
  from_port   = 6443
  to_port     = 6443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "allow_ssh_inbound_http" {
  description = "allow ssh into the nodes from anywhere"

  # allow ssh into the nodes from specific CIDR blocks
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "allow_ssh_inbound_https" {
  description = "allow ssh into the nodes from anywhere"

  # allow ssh into the nodes from specific CIDR blocks
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "allow_node_to_node" {
  description = "allow internal communication between the instances"

  # Allow inbound tcp calls from the internal cluster communication port generated only from the cluster nodes
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "all"
  # self, when set to true, adds the security group itself as a source to this ingress rule
  # this limits this ingress role to only nodes attached to this cluster
  self = true

  security_group_id = aws_security_group.security_group.id
}
