terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "on-demand-envs-terraform-state"
    key    = "states/back"
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

data "template_file" "user_data" {
  template = file("${path.module}/user-data/user-data.sh")
  vars = {
    APP_DIR = "back"
    DB_URL = "postgresql://${local.db_name}:${local.db_password}@${aws_db_instance.db.address}:5432/mydb?schema=public"
  }
}

module "ec2-backend" {
  source = "../commons/ec2-node"

  ami = "ami-076309742d466ad69"
  app_dir = "back"
  app_name = "${terraform.workspace}-on-demand-envs-poc"
  app_port = "4000"
  vpc_id = data.terraform_remote_state.core.outputs.vpc_id
  vpc_subnet = data.terraform_remote_state.core.outputs.vpc_public_subnet_1_id
  user_data = data.template_file.user_data.rendered
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  db_name     = "postgres"
  db_password = random_password.password.result
}

resource "aws_db_instance" "db" {
  allocated_storage    = 10
  db_name              = "${terraform.workspace}-on-demand-envs-poc-db"
  engine               = "postgresql"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = random_password.password.result
  skip_final_snapshot  = true
}
