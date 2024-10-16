###############################################################################################
#                                     GLOBAL VARIABLE                                         #
###############################################################################################

variable "name" {
  type    = string
  default = "webfarm"
}


###############################################################################################
#                                         IAM MODULE                                          #
###############################################################################################

// IAM-Role module
module "iam_roles" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Roles"

  name          = var.name

  tags_iam_role = { 
    Name        = var.name
  }
}

// IAM-Policies managed AWS
module "iam_policy_managed_sqs" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Policies_managed"
  depends_on = [ module.iam_roles ]

  policy_managed_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  role_attach_policy_managed_name = module.iam_roles.iam_role_name
}


// IAM-Policies managed yourself
module "iam_policy_ec2" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Policies_custom"
  depends_on = [ module.iam_roles ]

  policy_name        = "ec2_customized_policy"
  policy_description = "Custom policy to ec2 resources"
  policy_path        = "/"
  policy_document    = file("./json_policy/ec2_policy.json")
  role_attach_policy_managed_name = module.iam_roles.iam_role_name
}

module "iam_policy_s3" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Policies_custom"
  depends_on = [ module.iam_roles ]

  policy_name        = "s3_customized_policy"
  policy_description = "Custom policy to S3 resources"
  policy_path        = "/"
  policy_document    = file("./json_policy/s3_policy.json")
  role_attach_policy_managed_name = module.iam_roles.iam_role_name
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

// Security Group Custom 1
module "sg_custom_1" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/SecurityGroup/Custom"

  name = "${var.name}-all-custom-1"
  vpc_id  = "vpc-0b64f4e753bd58a43"
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "http access from internal network"
      cidr_blocks = "10.10.10.0/24"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https access from internal network"
      cidr_blocks = "10.10.10.0/24" 
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Mysql access from internal network"
      cidr_blocks = "192.168.10.0/24" 
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh access from internal network"
      cidr_blocks = "10.10.10.0/24"
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
    "Name" = "${var.name}-all-custom-1"
  }
}

// Security Group Custom 2
module "sg_custom_2" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/SecurityGroup/Custom"

  name   = "${var.name}-all-custom-2"
  vpc_id  = "vpc-0b64f4e753bd58a43"

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "http access from internal network"
      cidr_blocks = "10.10.10.0/24"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https access from internal network"
      cidr_blocks = "10.10.10.0/24" 
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Mysql access from internal network"
      cidr_blocks = "192.168.10.0/24" 
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh access from internal network"
      cidr_blocks = "10.10.10.0/24"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = -1
      description = "anywhere"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = 6
      description = "anywhere"
      cidr_blocks = "10.10.10.0/24"
    }
  ]
  tags = {
    "Name" = "${var.name}-all-custom-2"
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
  security_groups = [ module.sg_custom_1.sg_id ]

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



module "nlb_internal" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/LB"

  name    = "${var.name}-nlb-internal-jfrog"
  vpc_id  = "vpc-0b64f4e753bd58a43"
  subnets = ["subnet-0d12adc35523a85ac", "subnet-0d64ef80e224172bd", "subnet-0a6aac5ecd6d4b1bb"]
  security_groups = [ module.sg_custom_1.sg_id ]

  load_balancer_type         = "network"
  enable_deletion_protection = false
  internal = true
  enable_cross_zone_load_balancing = true
  tags = {
    "Name" = "jfrog-artifactory-nlb"
  }
  // Listeners
  listeners = {
    // Primeiro Listener
    tcp_8082 = {
      port     = 8082
      protocol = "TCP"

      forward = {
        target_group_key = "jfrog-artifactory-tg"
      }
    },
    // Segundo Listener
    tcp_8080 = {
      port     = 8080
      protocol = "TCP"

      forward = {
        target_group_key = "jfrog-artifactory-tg"
      }
    }
  }
  // Inicio Target Group
  target_groups = {
    // Primeiro targetgroup
    jfrog-artifactory-tg = {
      protocol    = "TCP"
      port        = 8082
      target_type = "instance"
      target_id   = module.wf-instance-02.instance_id    // Obrigatorio target_id
    }
  }
// Fim Target Group
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
  vpc_security_group_ids = [ module.sg_custom_1.sg_id, module.sg_custom_2.sg_id ]

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
  iam_instance_profile    = "${var.name}_instance_profile-02"
  instance_type           = "t2.micro"
  associate_public_ip     = false
  monitoring              = false
  vpc_security_group_ids  = [ module.sg_http.sg_id ]

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