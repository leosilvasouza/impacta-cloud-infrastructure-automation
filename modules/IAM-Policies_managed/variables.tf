########################################################################
# IAM Policies
########################################################################

variable "role_attach_policy_managed_name" {
  description = "Name of the IAM role"
  type = string
}

variable "policy_managed_arn" {
  description = "Name of the IAM policy optional"
}