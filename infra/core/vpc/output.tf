output "public_subnet_1" {
    value = aws_subnet.public_subnet_1
}

output "public_subnet_2" {
    value = aws_subnet.public_subnet_2
}

output "private_subnet_1" {
    value = aws_subnet.private_subnet_1
}

output "private_subnet_2" {
    value = aws_subnet.private_subnet_2
}

output "security_group_id" {
    value = aws_vpc.main.default_security_group_id
}

output "vpc_id" {
    value = aws_vpc.main.id
}
