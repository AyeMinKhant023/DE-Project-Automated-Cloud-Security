provider "aws" {
  region = var.aws_region
}

# 1. VPC Module (6 Subnets across 2 AZs, NAT, IGW, Route Tables, DB Subnet Group)
module "vpc" {
  source = "./modules/vpc"
}

# 2. ALB Module (Public Load Balancer + Target Group on Port 5000)
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

# 3. ASG Module (Private EC2 nodes + Launch Template + systemd service)
module "asg" {
  source                 = "./modules/asg"
  vpc_id                 = module.vpc.vpc_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  alb_security_group_id  = module.alb.alb_security_group_id
  target_group_arn       = module.alb.target_group_arn
  key_name               = var.key_name
}

# 4. WAF Module (Edge Perimeter Hardening for ALB)
module "waf" {
  source  = "./modules/waf"
  alb_arn = module.alb.alb_arn
}
