resource "aws_instance" "ec2_backend_server" {
  ami           = var.ami
  vpc_security_group_ids      = [aws_security_group.sg_backend_server.id]
  associate_public_ip_address = true
  subnet_id                   = var.vpc_subnet
  user_data                   = data.template_file.user_data.rendered
  instance_type = "t2.micro"
  tags = {
    Name = "${var.app_name}-ec2"
  }
}

data "template_file" "user_data" {
  template = file("user-data/user-data.sh")
  vars = {
    APP_DIR = var.app_dir,
  }
}

resource "aws_security_group" "sg_backend_server" {
  name   = "${var.app_name}-sg"
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.app_name}-sg"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = "0.0.0.0/0"
    description = "Allow ssh access to specefic IPs only"

  }
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
    description = "Allow HTTP traffic to the instance"
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
