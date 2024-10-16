########################################################################
## EBS additional 
########################################################################

resource "aws_ebs_volume" "additional_volumes" {
# checkov:skip=CKV_AWS_135: It was a customer request do not create the root EBS volume
# checkov:skip=CKV_AWS_8: It was a customer request do not create the root EBS volume
# checkov:skip=CKV_AWS_189: It is a customer requirement to use aws managed key 

  count = length(var.ebs_volumes)

  availability_zone = data.aws_instance.instance.availability_zone
  kms_key_id        = data.aws_kms_alias.kms_key.id
  size              = var.ebs_volumes[count.index].volume_size
  type              = var.ebs_volumes[count.index].volume_type
  iops              = var.ebs_volumes[count.index].volume_type == "gp3" ? var.ebs_volumes[count.index].iops : null
  encrypted         = var.ebs_volumes[count.index].encrypted
  final_snapshot    = var.ebs_volumes[count.index].final_snapshot
  tags              = var.ebs_volumes[count.index].tags
  multi_attach_enabled = var.ebs_volumes[count.index].multi_attach_enabled
}

resource "aws_volume_attachment" "attachment" {
  count       = length(var.ebs_volumes)
  
  device_name = var.ebs_volumes[count.index].device_name
  volume_id   = aws_ebs_volume.additional_volumes[count.index].id
  instance_id = var.instance_id
}

data "aws_instance" "instance" {
  instance_id = var.instance_id
}

data "aws_kms_alias" "kms_key" {
  name = var.kms_key_alias
}