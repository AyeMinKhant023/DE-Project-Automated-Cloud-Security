variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "List of private app subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID of the ALB"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB Target Group"
  type        = string
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
  default     = "my-project-key"
}
