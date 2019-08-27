locals {
  # Mumbai
  my_region                 = "eu-west-1"
  my_env                    = "dev"
  my_prefix                 = "flaconi"
  vpc_cidr_block            = "10.0.0.0/16"
  app_port                  = "80"
  elb_port                  = "80"
  availability_zone         = "eu-west-1a"
}

terraform {
  required_version = ">=0.11.11"
  backend "s3" {
    bucket         = "devops-sandboxx"
    key            = "state/sandbox.0.7.tfstate"
    region         = "ap-south-1"
    access_key     = ""
    secret_key     = ""
    dynamodb_table = "statelock-sandbox"
  }
}

provider "aws" {
  region     = "${local.my_region}"
  access_key = ""
  secret_key = ""
}

module "dev" {
  source                    = "../../Modules/root"
  prefix                    = "${local.my_prefix}"
  env                       = "${local.my_env}"
  region                    = "${local.my_region}"
  vpc_cidr_block            = "${local.vpc_cidr_block}"
  app_port                  = "${local.app_port}"
  elb_port                  = "${local.elb_port}"
  availability_zone         = "${local.availability_zone}"
}