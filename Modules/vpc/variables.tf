variable "prefix" {}
variable "env" {}
variable "region" {
  default     = "eu-west-1"
}
variable "vpc_cidr_block" {
}
variable "app_port" {}
variable "elb_port" {}
variable "availability_zone" {}
