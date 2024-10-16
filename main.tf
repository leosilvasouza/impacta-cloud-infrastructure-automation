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
#                                         LB MODULE                                           #
###############################################################################################

module "alb" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/LB"
  depends_on = [ module.wf-instance-01 ]

  name    = "${var.name}-alb"
  vpc_id  = "vpc-0b64f4e753bd58a43"
  subnets = ["subnet-0d12adc35523a85ac", "subnet-0d64ef80e224172bd", "subnet-0a6aac5ecd6d4b1bb"]
  security_groups = [ module.sg_http.sg_id ]

  enable_deletion_protection = false
  // Listener with redirect
  listeners = {
    // Inicio do Primeiro listener
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  }   
  // Inicio Target Group
  target_groups = {
    instance = {
      name_prefix = "tg-"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = module.wf-instance-01.instance_id   // Obrigatorio target_id se for instance em target_type
    }
  }
// Fim Target Group
  tags = {
    "Environment" = "Dev"
  }
}



###############################################################################################
#                                         EC2 MODULE                                          #
###############################################################################################

# Instance standalone, windows, with adittional EBS Volume, without associate to ALB through target_group_arn variable, without instance profile association

module "wf-instance-01" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EC2"
  depends_on = [ module.sg_custom_1, module.sg_custom_2 ]

  name                   = "${var.name}-instance-01"
  ami_name               = "ami-windows-2019-basic"
  os_instance            = "windows"
  key_name               = "key-webfarm-windows"
  
  instance_type          = "t2.micro"
  kms_key_alias          = "alias/default"
  associate_public_ip    = false
  monitoring             = false
  vpc_security_group_ids = [ module.sg_http.sg_id ]

  tags = {
    "Name" = "${var.name}-instance-01"
  }
}

# Instance standalone, linux, without adittional EBS Volume, without associate to ALB through target_group_arn variable, with instance profile association

module "wf-instance-02" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EC2"
  depends_on = [ module.sg_http ]

  name                    = "${var.name}-instance-02"
  ami_name                = "ami-linux-rhel7-basic"
  os_instance             = "linux"
  key_name                = "key-ec2-linux"
  
  create_instance_profile = true
  instance_type           = "t2.micro"
  associate_public_ip     = false
  monitoring              = false
  vpc_security_group_ids  = [ module.sg_http.sg_id ]
  associate_ec2_to_lb     = true
  target_group_arn        = module.alb.target_group_arn

  tags = {
    "Name" = "${var.name}-instance-02"
  }
}



###############################################################################################
#                                         EBS MODULE                                          #
###############################################################################################



module "ebs_volumes_wf-instance-01" {
  source        = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EBS"

  instance_id   = module.wf-instance-01.instance_id
  depends_on    = [ module.wf-instance-01 ]
  
  kms_key_alias = "alias/default"

  ebs_volumes = [
    {
      device_name          = "/dev/sdf"
      volume_size          = 50
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      kms_key_alias        = "alias/default"
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
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume2-nainstancia1"
      }
    },
    {
      device_name          = "/dev/sdh"
      volume_size          = 30
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume3-nainstancia1"
      }
    },        
    {
      device_name          = "/dev/sdi"
      volume_size          = 10
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume4-nainstancia1"
      }
    },
    {
      device_name          = "/dev/sdj"
      volume_size          = 20
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume5-nainstancia1"
      }
    }       
    // Adicione quantos volumes EBS adicionais desejar aqui
  ]
}