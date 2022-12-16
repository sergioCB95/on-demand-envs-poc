output ec2_url {
  value = "https://${aws_instance.ec2_backend_server.public_dns}:${var.app_port}"
}

output ec2_sg_id {
  value = aws_security_group.sg_backend_server.id
}
