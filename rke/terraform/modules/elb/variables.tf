# ------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "The Name of the VPC."
}

variable "autoscaling_group_name" {
  type        = string
  description = "The Name of the auto scalin group."
}

variable "security_group_id" {
  type        = string
  description = "The Security Group ID for the instances."
}

variable "subnet_id" {
  type        = string
  description = "The Subnet ID for the instances."
}
