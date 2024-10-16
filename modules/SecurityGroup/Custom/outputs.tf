output "sg_arn" {
  description = "The ARN of the security group"
  value       = try(aws_security_group.custom_sg[0].arn, "")
}

output "sg_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.custom_sg[0].id, "")
}

output "sg_vpc_id" {
  description = "The VPC ID"
  value       = try(aws_security_group.custom_sg[0].vpc_id, "")
}

output "sg_owner_id" {
  description = "The owner ID"
  value       = try(aws_security_group.custom_sg[0].owner_id, "")
}

output "sg_name" {
  description = "The name of the security group"
  value       = try(aws_security_group.custom_sg[0].name, "")
}

output "sg_description" {
  description = "The description of the security group"
  value       = try(aws_security_group.custom_sg[0].description, "")
}