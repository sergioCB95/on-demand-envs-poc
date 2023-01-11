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
    DATABASE_URL = "postgresql://${local.db_name}:${urlencode(local.db_password)}@${aws_db_instance.db.address}:5432/mydb?schema=public"
  }
}

module "ec2-backend" {
  source = "../../infra/commons/ec2-node"

  ami = "ami-076309742d466ad69"
  app_name = "${terraform.workspace}-on-demand-envs-poc-back"
  app_port = "4000"
  vpc_id = data.terraform_remote_state.core.outputs.vpc_id
  vpc_subnet = data.terraform_remote_state.core.outputs.vpc_public_subnet_1_id
  user_data = data.template_file.user_data.rendered
}

resource "random_password" "password" {
  length            = 40
  special           = false
  keepers           = {
    pass_version  = 1
  }
}

locals {
  db_name     = "postgres"
  db_password = random_password.password.result
}


resource "aws_security_group" "database_sg" {
  name   = "${terraform.workspace}-on-demand-envs-poc-db-sg"
  vpc_id = data.terraform_remote_state.core.outputs.vpc_id
  tags = {
    Name = "${terraform.workspace}-on-demand-envs-poc-db-sg"
  }

  ingress {
    protocol    = "tcp"
    description = "Allow HTTP traffic to the instance"
    from_port = 5432
    to_port = 5432
    security_groups = [module.ec2-backend.ec2_sg_id]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${terraform.workspace}_on_demand_envs_poc_db_subnet_group"
  subnet_ids = [
    data.terraform_remote_state.core.outputs.vpc_public_subnet_1_id,
    data.terraform_remote_state.core.outputs.vpc_public_subnet_2_id,
    data.terraform_remote_state.core.outputs.vpc_private_subnet_1_id,
    data.terraform_remote_state.core.outputs.vpc_private_subnet_2_id
  ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "db" {
  snapshot_identifier  = var.db_snapshot_id
  allocated_storage    = 10
  identifier           = "${terraform.workspace}-on-demand-envs-poc-db"
  db_name              = "mydb"
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = random_password.password.result
  skip_final_snapshot  = true
  vpc_security_group_ids  = [aws_security_group.database_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
}
