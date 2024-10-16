locals {
  instance_profile_count = var.create_instance_profile ? 1 : 0
}

data "aws_ami" "ami_filter" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "tag:Name"
    values = [var.ami_name]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


data "aws_kms_alias" "root_block_ebs" {
  name = var.kms_key_alias
}

########################################################################
## EC2 session 
########################################################################

resource "aws_instance" "this" {
# checkov:skip=CKV_AWS_135: It was a customer request do not create the root EBS volume
# checkov:skip=CKV_AWS_8: It was a customer request do not create the root EBS volume
# checkov:skip=CKV_AWS_189: It is a customer requirement to use aws managed key 

  ami                                  = data.aws_ami.ami_filter.id
  instance_type                        = var.instance_type
  hibernation                          = var.hibernation
  iam_instance_profile                 = var.create_instance_profile ? aws_iam_instance_profile.ec2_instance_profile[0].name : null
  user_data                            = var.user_data
  user_data_base64                     = var.user_data_base64
  user_data_replace_on_change          = var.user_data_replace_on_change

  availability_zone                    = var.availability_zone
  subnet_id                            = var.subnet_id
  
  key_name                             = var.key_name
  monitoring                           = var.monitoring
  get_password_data                    = var.get_password_data

  root_block_device {
    encrypted             = true
    kms_key_id            = data.aws_kms_alias.root_block_ebs.target_key_arn
  }

  ebs_block_device {
      device_name         = var.os_instance == "linux" ? var.name_ebs_pagefile_linux  : (var.os_instance == "windows" ? var.name_ebs_pagefile_windows  : "")
      encrypted           = true
      kms_key_id          = data.aws_kms_alias.root_block_ebs.target_key_arn
    }

  associate_public_ip_address          = var.associate_public_ip
  private_ip                           = var.private_ip
  secondary_private_ips                = var.secondary_private_ips
  ipv6_address_count                   = var.ipv6_address_count
  ipv6_addresses                       = var.ipv6_addresses
  vpc_security_group_ids               = var.vpc_security_group_ids

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.os_instance == "linux" ? var.instance_tags_linux : var.os_instance == "windows" ? var.instance_tags_windows : {},
    (var.environment == "dev" || var.environment == "uat" || var.environment == "NonProd") ? { "schedule" =   "nonprod-sp-office-hours" } : {},
    var.environment == "PROD" ? { "schedule" = "prod-sp-office-hours" } : {}
  )

  source_dest_check                    = length(var.network_interface) > 0 ? null : var.source_dest_check
  disable_api_termination              = var.disable_api_termination
  disable_api_stop                     = var.disable_api_stop
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  tenancy                              = var.tenancy
  host_id                              = var.host_id
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags = null
  }

  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [ aws_iam_instance_profile.ec2_instance_profile ]
}

resource "aws_ec2_tag" "root_block_ebs" {
  resource_id = aws_instance.this.root_block_device[0].volume_id
  key         = "Name"
  value       = "${var.name}-${var.tag_root_block_device}"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  count = local.instance_profile_count

  name = "${var.name}_instance_profile"
  role = var.iam_role_ec2_role_name
  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.os_instance == "linux" ? var.instance_tags_linux : var.os_instance == "windows" ? var.instance_tags_windows : {},
    (var.environment == "dev" || var.environment == "uat" || var.environment == "NonProd") ? { "schedule" =   "nonprod-sp-office-hours" } : {},
    var.environment == "PROD" ? { "schedule" = "prod-sp-office-hours" } : {}
  )
}


########################################################################
## LB session 
########################################################################

locals {
  effective_target_group_type = var.associate_ec2_to_lb ? var.target_group_type : ""
}

# Target Group Attachment for Instance type
resource "aws_lb_target_group_attachment" "ec2_attachment_instance" {
  count = var.associate_ec2_to_lb && local.effective_target_group_type == "instance" ? 1 : 0

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this.id
  port             = var.target_group_port
}


# Target Group Attachment for IP type
resource "aws_lb_target_group_attachment" "ec2_attachment_ip" {
  count = var.associate_ec2_to_lb && local.effective_target_group_type == "ip" ? 1 : 0

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this.private_ip
  port             = var.target_group_port
}