variable app_name {
  description = "Application name"
}

variable app_port {
  description = "Application port"
}

variable ami {
  description = "EC2 AMI Id"
}

variable vpc_id {
  description = "VPC Id"
}

variable vpc_subnet {
  description = "VPC Subnet"
}

variable user_data {
  description = "User data entity"
  type = string
}
