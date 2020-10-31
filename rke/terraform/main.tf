terraform {
  required_version = ">= 0.13, < 0.14"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  name = "rke"
  public_subnet = "11.11.11.0/28"
  availability_zone = "us-east-1a"
}

resource "aws_key_pair" "rke" {
  key_name   = "rke-key"
  public_key = file("sample.pub")
}

resource "aws_vpc" "vpc" {
  cidr_block = "11.11.11.0/28"

  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name}-internet-gateway"
    VPC  = local.name 
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = local.availability_zone

  cidr_block        = local.public_subnet 

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name}-public-subnets-route-table"
    VPC  = local.name 
  }
}

resource "aws_route_table_association" "public_subnets_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

# create a route that routes traffic from / to all ip addresses ranges through internet gateway
# this what makes a subnet a public one
resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public_subnets_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# ------------------------------------------------------------------------------------------------------------------
# CREATE NAT GATEWAYS THAT PRIVATE SUBNETS WILL USE TO CONNECT TO INTERNET
# ------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name   = "${local.name}-public-subnet-nat-gateway-eip"
    VPC    = local.name
    Subnet = aws_subnet.public_subnet.id
  }

  # EIP may require IGW to exist prior to association. Use depends_on to set an explicit dependency on the IGW.
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_gateways" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.id 

  # It is recommended to denote that the NAT Gateway depends on the Internet Gateway for the VPC in which the NAT Gateway's subnet is located.
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name = "rke"
  # availability_zones = [local.availability_zone]
  launch_configuration = aws_launch_configuration.launch_configuration.name
  vpc_zone_identifier = [aws_subnet.public_subnet.id]

  min_size = 3
  max_size = 3
  desired_capacity = 3

  termination_policies = ["OldestInstance", "OldestLaunchConfiguration"]

  health_check_grace_period = 5

  health_check_type = "EC2"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix = "rke"
  image_id = "ami-0817d428a6fb68645"
  instance_type = "t2.medium"

  user_data = file("user_data.sh")
  key_name = aws_key_pair.rke.key_name
  security_groups = [aws_security_group.security_group.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "security_group" {
  name        = local.name
  description = "The security group for rke instance."

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = local.name
  }

  # aws_launch_configuration.launch_configuration in the elasticsearch-autoscaling-group
  # module sets create_before_destroy to true.
  # This means everything it depends on, including this resource, must set it as well.
  # Otherwise, you get cyclic dependency errors when you try to run terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------------------------------------------
# ATTACH SECURITY GROUP RULES THAT CONTROL WHAT TRAFFIC CAN GO IN AND OUT OF THE ELASTICSEARCH CLUSTER
# ------------------------------------------------------------------------------------------------------------------

# Allow elasticsearch cluster nodes to communicate with the outside world
resource "aws_security_group_rule" "allow_all_outbound" {
  description = "allow all outbound communications from the elasticsearch cluster nodes to the internet"

  # allow all outbound calls from any port with any protocol to any ip address
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.security_group.id
}

# Allow ssh into the elasticsearch cluster nodes from specific IP ranges
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

