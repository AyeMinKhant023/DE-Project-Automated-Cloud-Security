variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
  default     = "my-project-key"
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}
