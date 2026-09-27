output "application_url" {
  description = "Public URL to access the application via the Application Load Balancer"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  description = "Direct DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of private app subnet IDs"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  value       = module.vpc.private_db_subnet_ids
}

output "db_subnet_group_name" {
  description = "The RDS DB subnet group name"
  value       = module.vpc.db_subnet_group_name
}
