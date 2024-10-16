########################################################################
# IAM Role
########################################################################

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "Multiples Policies managed by AWS attached to the IAM role"
  type        = list(string)
  default     = null
}

variable "name" {
  type    = string
}

variable "tags_iam_role" {
  type    = map(string)
  default = null
}