output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_public_subnet_1_id" {
  value = module.vpc.public_subnet_1_id
}

output "vpc_public_subnet_2_id" {
  value = module.vpc.public_subnet_2_id
}

output "vpc_private_subnet_1_id" {
  value = module.vpc.private_subnet_1_id
}

output "vpc_private_subnet_2_id" {
  value = module.vpc.private_subnet_1_id
}

output "vpc_security_group_id_id" {
  value = module.vpc.security_group_id
}
