provider "aws" {
  region = "your_region"
}

module "vpc" {
  source = "./modules/vpc"
  # You can provide variables if needed
}

module "ecs" {
  source = "./modules/ecs"
  vpc_id = module.vpc.vpc_id
  # Other variables for ECS setup
}

module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  # Other variables for EC2 setup
}

module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  # Other variables for RDS setup
}