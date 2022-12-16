output ec2_url {
  value = "https://${aws_instance.ec2_backend_server.public_dns}:${var.app_port}"
}
