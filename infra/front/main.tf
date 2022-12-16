terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "on-demand-envs-terraform-state"
    key    = "states/front"
    region = "eu-central-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}

data "terraform_remote_state" "core" {
  backend = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "on-demand-envs-terraform-state"
    key = "states/core"
    region  = "eu-central-1"
  }
}

data "terraform_remote_state" "back" {
  backend = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "on-demand-envs-terraform-state"
    key = "states/back"
    region  = "eu-central-1"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data/user-data.sh")
  vars = {
    APP_DIR = "back"
    BACKEND_URL = data.terraform_remote_state.back.outputs.ec2_url
  }
}

module "ec2-backend" {
  source = "../commons/ec2-node"

  ami = "ami-076309742d466ad69"
  app_name = "${terraform.workspace}-on-demand-envs-poc"
  app_port = "3000"
  vpc_id = data.terraform_remote_state.core.outputs.vpc_id
  vpc_subnet = data.terraform_remote_state.core.outputs.vpc_public_subnet_1_id
  user_data = data.template_file.user_data.rendered
}
