output "ebs_volume_ids" {
  description = "IDs dos volumes EBS criados."
  value       = aws_ebs_volume.additional_volumes[*].id
}

output "attached_volume_ids" {
  description = "IDs dos volumes EBS anexados à instância EC2."
  value       = aws_volume_attachment.attachment[*].id
}