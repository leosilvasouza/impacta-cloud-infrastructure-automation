output "iam_policy_arn" {
  description = "ARN of the created IAM policy"
  value       = aws_iam_policy.iam_policy.arn
}