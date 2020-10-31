terraform {
  required_version = ">= 0.13, < 0.14"

  required_providers {
    # REQUIRE SPECIFIC AWS PROVIDER VERSION
    # This module has been developed with AWS provider version 3.3.0, which means it is not compatible with any version below 3.3.0
    aws = {
      version = ">= 3.3.0, < 4.0.0"
    }
  }
}

locals {
  name                     = "rke"
  region                   = "us-east-1"
  availability_zone        = "us-east-1a"
  vpc_cidr_block           = "11.11.11.0/28"
  public_subnet_cidr_block = "11.11.11.0/28"
}

provider "aws" {
  region = local.region
}

resource "aws_key_pair" "rke" {
  key_name   = "rke-key"
  public_key = file("sample.pub")
}

module "vpc" {
  source = "./modules/vpc"

  name                     = local.name
  availability_zone        = local.availability_zone
  vpc_cidr_block           = local.vpc_cidr_block
  public_subnet_cidr_block = loca.subnet_cidr_block
}

module "autoscaling_group" {
  source = "./modules/autoscaling-group"

  name              = local.name
  public_subnet_id  = module.vpc.public_subnet_id
  key_pair_name     = aws_key_pair.rke.key_name
  security_group_id = module.security_group.security_group_id
}

module "security_group" {
  source = "./modules/security-group"

  name   = local.name
  vpc_id = modules.vpc.vpc_id
}
