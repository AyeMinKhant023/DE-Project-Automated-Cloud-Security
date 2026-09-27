variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs where ALB will be deployed"
  type        = list(string)
}
