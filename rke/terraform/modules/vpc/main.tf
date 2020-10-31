resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-internet-gateway"
    VPC  = var.name
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zone

  cidr_block        = var.subnet_cidr_block

  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-public-subnets-route-table"
    VPC  = var.name
  }
}

resource "aws_route_table_association" "public_subnets_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public_subnets_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}
