########################################################################
# IAM Policies
########################################################################

variable "policy_name" {
  description = "Name of the IAM policy"
}

variable "policy_description" {
  description = "Description of the IAM policy"
}

variable "policy_path" {
  description = "Path for the IAM policy"
}

variable "policy_document" {
  description = "JSON string representing the IAM policy document"
}

variable "role_attach_policy_managed_name" {
  description = "Name of the IAM role"
  type = string
  default = null
}

variable "attach_policy_in_role" {
  description = "Condition to attach or not policy in role, because have some policy that is not necessary a role"
  type = bool
  default = true
}