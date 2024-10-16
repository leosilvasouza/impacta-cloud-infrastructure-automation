#######################################################################
# Creation Role
#######################################################################

resource "aws_iam_role" "role_webfarm" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

  permissions_boundary = var.iam_role_permissions_boundary

  tags = var.tags_iam_role
}