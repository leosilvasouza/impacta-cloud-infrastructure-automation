################################################################################
# EC2 Normal Instances
################################################################################

variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}

variable "ami_name" {
  description = "Nome para o nome da AMI"
  type        = string
}

variable "ami_owners" {
  description = "Owners da AMI"
  type        = list(string)
  default     = [ "self" ]
}

variable "iam_role_ec2_role_name" {
  description = "Role name to convert in instance profile"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "Instance profile"
  type        = string
  default     = null
}

variable "create_instance_profile" {
  type    = bool
  default = false
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set"
  type        = bool
  default     = null
}

variable "get_password_data" {
  description = "If true, wait for password data to become available and retrieve it"
  type        = bool
  default     = null
}

variable "hibernation" {
  description = "If true, the launched EC2 instance will support hibernation"
  type        = bool
  default     = null
}

variable "host_id" {
  description = "ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host"
  type        = string
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instance"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "m5a.large"
}

variable "os_instance" {
  description = "The Operation System of instance"
  type        = string
}

variable "instance_tags_windows" {
  description = "Additional tags for the instance"
  type        = map(string)
  default     = {
    "terraform" = "true"
    "maintenance_window" = "true"
    "backup" = "false"
    "backup_scheduler" = "daily_ec2"
    "os" = "windows"
  }
}

variable "instance_tags_linux" {
  description = "Additional tags for the instance"
  type        = map(string)
  default     = {
    "terraform" = "true"
    "maintenance_window" = "false"
    "backup" = "false"
    "backup_scheduler" = "daily_ec2"
    "os" = "linux"
  }
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = null
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "kms_key_alias" {
  type    = string
  default = "alias/hdi_default"
}

variable "tag_root_block_device" {
  type    = string
  default = "Root"
}

################################################################################
# Network interface session
################################################################################

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(map(string))
  default     = []
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet"
  type        = number
  default     = null
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  type        = list(string)
  default     = null
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Public IP address to associate with the instance in a VPC"
  type        = string
  default     = false
}

variable "secondary_private_ips" {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a `network_interface block`"
  type        = list(string)
  default     = null
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs"
  type        = bool
  default     = null
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
  default     = null
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with by default VPC"
  type        = list(string)
  default     = null
}

variable "disable_api_stop" {
  description = "If true, enables EC2 Instance Stop Protection"
  type        = bool
  default     = null

}

variable "target_group_arn" {
  description = "The ARN of the target group. Required if associate_ec2_to_lb is true."
  type        = any
  default     = null
}

variable "associate_ec2_to_lb" {
  description = "Flag to associate EC2 instance with the Load Balancer"
  type        = bool
  default     = false
}

variable "target_group_port" {
  description = "The port on which the target receives traffic."
  type        = number
  default     = 80
}

variable "target_group_type" {
  description = "The type of the target group (instance or ip)."
  type        = string
  default     = ""
  validation {
    condition = contains(["", "instance", "ip"], var.target_group_type)
    error_message = "target_group_type must be either 'instance', 'ip' or empty."
  }
}

variable "name_ebs_pagefile_linux" {
  type = string
  default = "/dev/xvdd"
}

variable "name_ebs_pagefile_windows" {
  type = string
  default = "/dev/sda1"
}