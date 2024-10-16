#######################################################################
# Creation Policy
#######################################################################

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = var.role_attach_policy_managed_name
  policy_arn = var.policy_managed_arn
}