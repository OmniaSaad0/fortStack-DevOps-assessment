

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

# Security Groups Module
module "security" {
  source = "./modules/security"
  
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

# EC2 Instances Module
module "ec2" {
  source = "./modules/ec2"
  
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  control_plane_sg_id       = module.security.control_plane_sg_id
  worker_node_sg_id         = module.security.worker_node_sg_id
  environment              = var.environment
  instance_type            = var.instance_type
  key_name                = var.key_name
  control_plane_count     = var.control_plane_count
  worker_node_count       = var.worker_node_count
  ami_id                  = var.ami_id
} 