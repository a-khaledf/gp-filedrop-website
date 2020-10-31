# ------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "The Name of the Cluster."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID in which security group would be added."
}
