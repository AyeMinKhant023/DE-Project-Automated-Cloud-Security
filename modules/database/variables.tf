variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "app_security_group_id" {
  description = "Security Group ID of the EC2 App instances"
  type        = string
}

variable "db_password" {
  description = "Password for MySQL database"
  type        = string
  sensitive   = true
}

variable "kms_key_arn" {
  description = "KMS Key ARN for storage encryption"
  type        = string
}
