#######################################################################
# Creation Policy
#######################################################################

resource "aws_iam_policy" "iam_policy" {
  name        = var.policy_name
  description = var.policy_description
  path        = var.policy_path
  policy      = var.policy_document
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  count = var.attach_policy_in_role ? 1 : 0
  
  role       = var.role_attach_policy_managed_name
  policy_arn = aws_iam_policy.iam_policy.arn
}