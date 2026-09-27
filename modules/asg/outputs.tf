output "app_security_group_id" {
  description = "Security Group ID of the EC2 App instances"
  value       = aws_security_group.app_sg.id
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}
