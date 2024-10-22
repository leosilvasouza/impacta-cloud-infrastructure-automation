variable "instance_id" {
  description = "ID da instância EC2 à qual os volumes EBS serão anexados."
}

variable "ebs_volumes" {
  description = "Lista dos volumes EBS a serem criados e anexados à instância EC2."
  type        = list(object({
    device_name    = string
    volume_size    = number
    volume_type    = string
    iops           = number
    final_snapshot = bool
    tags           = map(string)
    multi_attach_enabled = bool
  }))
  default       = [
    {
    device_name    = "/dev/sdf"
    volume_size    = 100
    volume_type    = "gp2"
    iops           = 100
    final_snapshot = false
    tags = {
        Name = "/dev/sdf"
        "backup" = "weekly"
      }
    multi_attach_enabled = false  
    }
  ]
}
