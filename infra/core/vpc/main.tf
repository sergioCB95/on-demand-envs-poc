resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-VPC"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "Public Subnets"
    Network = "Public"
  }
}

resource "aws_eip" "eip_1" {
  vpc = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_eip" "eip_2" {
  vpc = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                    = aws_vpc.main.id
  availability_zone         = "eu-central-1a"
  map_public_ip_on_launch   = true
  cidr_block                = cidrsubnet(var.cidr_block, 2, 0)

  tags = {
    Name = "${var.vpc_name}-PublicSubnet01"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(var.cidr_block, 2, 1)

  tags = {
    Name = "${var.vpc_name}-PublicSubnet02"
  }
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_nat_gateway.nat_gateway_1, aws_subnet.public_subnet_1, aws_internet_gateway.internet_gateway]

  tags = {
    Name = "${var.vpc_name}-NatGatewayAZ1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id

  depends_on = [aws_nat_gateway.nat_gateway_2, aws_subnet.public_subnet_2, aws_internet_gateway.internet_gateway]

  tags = {
    Name = "${var.vpc_name}-NatGatewayAZ2"
  }
}


resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }

  depends_on = [aws_internet_gateway.internet_gateway, aws_nat_gateway.nat_gateway_1]

  tags = {
    Name = "Private Subnet AZ1"
    Network = "Private01"
  }
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }

  depends_on = [aws_internet_gateway.internet_gateway, aws_nat_gateway.nat_gateway_2]

  tags = {
    Name = "Private Subnet AZ2"
    Network = "Private02"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-central-1a"
  cidr_block        = cidrsubnet(var.cidr_block, 2, 2)

  tags = {
    Name = "${var.vpc_name}-PrivateSubnet01"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-central-1b"
  cidr_block        = cidrsubnet(var.cidr_block, 2, 3)

  tags = {
    Name = "${var.vpc_name}-PrivateSubnet02"
  }
}

resource "aws_route_table_association" "public_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table_association" "private_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}
