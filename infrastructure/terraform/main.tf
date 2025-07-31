
# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  environment        = var.environment
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr_block
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  
  instance_type     = var.instance_type
  key_name          = var.key_name
  ami_id            = var.ami_id
  
  app_port          = var.app_port
  ssh_port          = var.ssh_port
  mongo_port        = var.mongo_port
} 