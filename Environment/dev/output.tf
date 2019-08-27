output "private_subnet_ids" {
    description = "Private Subnet IDs"
    value       = "${module.dev.private_subnet_ids}"
}

output "public_subnet_ids" {
    description = "Public Subnet IDs"
    value       = "${module.dev.public_subnet_ids}"
}

output "vpc_id" {
    description = "VPC ID of our AWS VPC"
    value       = "${module.dev.vpc_id}"
}


output "elb_dns" {
    description = "DNS of the ELB"
    value       = "${module.dev.elb_dns_name}"
}

output "nat_eip" {
    description = "EIP of NAT Gateway"
    value = "${module.dev.nat_eip}"
}