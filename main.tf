###############################################################################################
#                                     GLOBAL VARIABLE                                         #
###############################################################################################

variable "name" {
  type    = string
  default = "webfarm"
}


###############################################################################################
#                                         SG MODULE                                           #
###############################################################################################

module "sg_http" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/SecurityGroup/webfarm-sg-http-80"

  name = "${var.name}-http-80"
  vpc_id  = "vpc-0b64f4e753bd58a43" 

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http access from internal network"
      cidr_blocks = "10.10.10.0/24"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http access from internal network"
      cidr_blocks = "192.168.10.0/24"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = -1
      description = "anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    "Name" = "${var.name}-http-80"
  }
}

###############################################################################################
#                                         EC2 MODULE                                          #
###############################################################################################

# Instance standalone, windows, with adittional EBS Volume, without associate to ALB through target_group_arn variable, without instance profile association

module "wf-instance-01" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EC2"
  depends_on = [ module.sg_http ]

  name                   = "${var.name}-instance-01"
  ami_name               = "ami-windows-basic"
  os_instance            = "windows"
  key_name               = "key-webfarm-windows"

  create_instance_profile = false
  instance_type          = "t2.micro"
  associate_public_ip    = false
  monitoring             = false
  vpc_security_group_ids = [ module.sg_http.sg_id ]

  tags = {
    "Name" = "${var.name}-instance-01"
  }
}

###############################################################################################
#                                         EBS MODULE                                          #
###############################################################################################



module "ebs_volumes_wf-instance-01" {
  source        = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EBS"

  instance_id   = module.wf-instance-01.instance_id
  depends_on    = [ module.wf-instance-01 ]
  
  ebs_volumes = [
    {
      device_name          = "/dev/sdf"
      volume_size          = 50
      volume_type          = "gp2"
      iops                 = 100
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume1-nainstancia1"
      }
    },
    {
      device_name          = "/dev/sdg"
      volume_size          = 40
      volume_type          = "gp2"
      iops                 = 100
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume2-nainstancia1"
      }
    }       
    // Adicione quantos volumes EBS adicionais desejar aqui
  ]
}
