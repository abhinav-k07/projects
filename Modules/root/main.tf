# NOTE: This is the environment definition that will be used by all environments.
# The actual environments (like dev) just inject their environment dependent values
# to this root module which defines the actual environment and creates that environment
# by injecting the environment related values to modules.


locals {
  my_name  = "${var.prefix}-${var.env}"
  my_env   = "${var.prefix}-${var.env}"
}


# VPC Module

module "vpc" {
  source                = "../vpc"
  prefix                = "${var.prefix}"
  env                   = "${var.env}"
  region                = "${var.region}"
  vpc_cidr_block        = "${var.vpc_cidr_block}"
  app_port              = "${var.app_port}"
  elb_port              = "${var.elb_port}"
  availability_zone     = "${var.availability_zone}"
}



# This is the actual compute module which creates EC2 Auto Scaling Group and Elastic Load Balancer (ELB).

module "compute" {
  source                       = "../compute"
  prefix                       = "${var.prefix}"
  env                          = "${var.env}"
  region                       = "${var.region}"
  private_subnet_ids           = "${module.vpc.private_subnet_ids}"
  public_subnet_ids            = "${module.vpc.public_subnet_ids}"
  app_port                     = "${var.app_port}"
  elb_port                     = "${var.elb_port}"
  vpc_id                       = "${module.vpc.vpc_id}"
  private_subnet_sg_id         = "${module.vpc.private_subnet_sg_id}"
  public-subnet-sg_id          = "${module.vpc.public-subnet-sg_id}"
  availability_zone            = "${var.availability_zone}"

}


