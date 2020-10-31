# ------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ------------------------------------------------------------------------------------------------------------------

variable "name" {
  type = string
  description = "The Name of the Cluster."
}

variable "public_subnet_id" {
  type = string
  description = "The Public Subnet ID to spawn the autoscaling group in."
}

variable "key_pair_name" {
  type = string
  description = "The Key Pair name to SSH the instances."
}

variable "security_group_id" {
  type = string
  description = "The Security Group for the instances."
}


# ------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ------------------------------------------------------------------------------------------------------------------

variable "instance_type" {
  type = string
  description = "The Instance Type for the instances to be spawned."
  default = "t2.medium"
}

variable "instance_image_id" {
  type = string
  description = "The AMI ID for the instances"
  default = "ami-0817d428a6fb68645"
}

variable "root_block_volume_size" {
  type = number
  description = "The Root Volume Size in Gigabyes."
  default = 10
}
