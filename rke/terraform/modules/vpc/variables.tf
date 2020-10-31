# ------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "The Name of the VPC."
}

variable "availability_zone" {
  type        = string
  description = "The Availability zone in which the VPC is created."
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC created."
}

variable "subnet_cidr_block" {
  type        = string
  description = "The CIDR blockf for the public subnet in the VPC created."
}

