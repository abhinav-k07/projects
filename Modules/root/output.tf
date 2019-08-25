output "private_subnet_ids" {
    description = "Private Subnet IDs"
    value       = "${module.vpc.private_subnet_ids}"
}

output "public_subnet_ids" {
    description = "Public Subnet IDs"
    value       = "${module.vpc.public_subnet_ids}"
}

output "vpc_id" {
    description = "VPC ID of our AWS VPC"
    value       = "${module.vpc.vpc_id}"
}

output "elb_dns_name" {
    description = "The DNS Name of the ELB"
    value       = "${module.compute.elb_dns_name}"
}

output "nat_eip" {
    description = "EIP of NAT Gateway"
    value = "${module.vpc.nat_eip}"
}
