output "iam_role_name" {
  value = aws_iam_role.role_webfarm.name
}

output "iam_role_arn" {
  value = aws_iam_role.role_webfarm.arn
}

output "iam_role_unique_id" {
  value = aws_iam_role.role_webfarm.unique_id
}