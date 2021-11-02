#
# DO NOT DELETE THESE LINES UNTIL INSTRUCTED TO!
#
# Your AMI ID is:
#
#     ami-083654bd07b5da81d
#
# Your subnet ID is:
#
#     subnet-0629a98fc0a77c14d
#
# Your VPC security group ID is:
#
#     sg-0ccb8fe39c51f87f4
#
# Your Identity is:
#
#     terraform-training-chicken
#

variable "access_key" {
  description = "AWS Access Key"
}

variable "secret_key" {
  description = "AWS Secret Key"
}

variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "ami" {
  description = "Server Image ID"
}

variable "subnet_id" {
  description = "Server Subnet ID"
}

variable "identity" {
  description = "Server Name"
}

variable "vpc_security_group_ids" {
  description = "Server Security Group ID(s)"
  type        = list(any)
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


locals {
  servers = {
    
    server-apache = {
      server_os              = "ubuntu_20_04"
      identity               = "$var.identity-ubuntu"
      subnet_id              = var.subnet_id
      vpc_security_group_ids = var.vpc_security_group_ids
    }
  }
}
data "terraform_remote_state" "ssh-keys" {
  backend = "remote"

  config = {
    hostname = "app.terraform.io"
    organization = "example-org-1a3aa2"

    workspaces = {
      name = "ssh-keys"
    }
  }
}
module "server" {
  source  = "app.terraform.io/example-org-1a3aa2/server/aws"
  version = "0.0.2"
  for_each               = local.servers
  server_os              = each.value.server_os
  identity               = each.value.identity
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.vpc_security_group_ids
  key_name               = data.terraform_remote_state.ssh-keys.outputs.key_name
}



output "public_ip" {
  description = "Public IP of the Servers"
  value       = { for p in sort(keys(local.servers)) : p => module.server[p].public_ip }
}

output "public_dns" {
  description = "Public DNS names of the Servers"
  value       = { for p in sort(keys(local.servers)) : p => module.server[p].public_dns }
}
