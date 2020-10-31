
resource "aws_vpc" "vpc" {
  cidr_block = "11.11.11.0/28"

  enable_dns_support = true
  enable_dns_hostnames = true
}
