output "db_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = aws_db_instance.database.endpoint
}

output "db_instance_id" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.database.identifier
}

output "db_security_group_id" {
  description = "Security group ID of the database"
  value       = aws_security_group.db_sg.id
}
