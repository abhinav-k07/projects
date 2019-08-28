# Flaconi Project - DevOps: Terraform + AWS 

## Table Of Contents

* [Introduction](#introduction)
* [Project Architecture](#project-architecture)
* [Terraform Code](#terraform-code)
* [Terraform Modules](#terraform-modules)
    * [Environment/Dev](https://github.com/abhinav-k07/projects/tree/master/Environment/dev)
    * [Compute](https://github.com/abhinav-k07/projects/tree/master/Modules/compute)
    * [Root](https://github.com/abhinav-k07/projects/tree/master/Modules/root)
    * [VPC](https://github.com/abhinav-k07/projects/tree/master/Modules/vpc)
* [Terraform Output](#terraform-output)
    



## Introduction

This AWS Cloud Environment is scripted using Terraform modular approach and AWS best practices. It demonstrates a single click deployment methodology to provision an AWS VPC having Web Servers hosted on EC2 instances running in an Auto Scaling Group. The AWS Cloud Architecture consists of an AWS VPC having resources deployed in public and private subnets as shown below in [Project Architecture](#project-architecture). The Terraform code is scripted using features like [Remote Backend - S3](https://www.terraform.io/docs/backends/types/s3.html) for state management and [DynamoDB](https://www.terraform.io/docs/state/locking.html) for state locking.

## Project Architecture

![alt text](https://raw.githubusercontent.com/abhinav-k07/projects/master/Flaconi%20Docs/Flaconi%20-%20DevOps%20AWS%20Cloud%20and%20Terraform.jpeg)

## Terraform Code

Terraform is used as an Infrastructure as a Code (IaC) tool for designing Flaconi AWS Cloud environment. The Terraform code consists of multiple modules comprising of [Environment/Dev](https://github.com/abhinav-k07/projects/tree/master/Environment/dev), [Compute](https://github.com/abhinav-k07/projects/tree/master/Modules/compute), [Root](https://github.com/abhinav-k07/projects/tree/master/Modules/root) and [VPC](https://github.com/abhinav-k07/projects/tree/master/Modules/vpc). It is a cloud best practice that we should modularize our Terraform code, so that we can create multiple different replicas of our infrastructure by re-using the infra modules. I have adopted a best practice to organize our terraform code in three levels: main.tf, variables.tf and output.tf.

* Main.tf - This file contains actual terraform code of resources which are provisioned inside our AWS Cloud environment like ELB, VPC, ASG etc.
* Output.tf - This file contains the output values which are extracted from the resources deployed through main.tf in AWS Cloud.
* Variables.tf - This file contains the variables which are parsed through main.tf.


## Terraform Modules

* [Environment/Dev](https://github.com/abhinav-k07/projects/tree/master/Environment/dev)
    * The Environment module will host multiple environments. In this illustration I have only configured the Dev environment, but this folder would have similar environment parameterisations for QA, Performance, Prod, Test etc. This module is variablised and parameterised to provide flexibility to the developer for provisioning multiple environments.

* [Compute](https://github.com/abhinav-k07/projects/tree/master/Modules/compute)
    * The Compute Module contains multiple resources like EC2 Instances, Auto Scaling Group, Launch Template Configuration, Elastic Load Balancer (ELB), Auto Scaling Policies and CloudWatch Metric Alarms. The Launch Template contains AMI details which are consumed by the Auto Scaling Group to deploy EC2 Instances inside Private Subnet.
    
* [Root](https://github.com/abhinav-k07/projects/tree/master/Modules/root)
    * In root folder we define the modules that will be used in every environment. The environments inject the environment specific parameters to the root module which then creates the actual infrastructure using those parameters by calling various infra modules and forwarding environment parameters to the infrastructure modules.

* [VPC](https://github.com/abhinav-k07/projects/tree/master/Modules/vpc)
    * The VPC Module provisions the networking components of our AWS Cloud environment like AWS VPC, Public & Private Subnets, Internet Gateway, NAT Gateway, Security Groups and Route Table configurations. The public subnet hosts ELB and NAT Gateway while the private subnet hosts the EC2 Instances running inside an ASG.


## Terraform Output

![alt text]()
