# Terraform Module for WEBFARM Module AWS EC2 Instances

Welcome to our Terraform module guide for deploying webfarm-ec2 insfrastructure. Terraform module which creates the Webfarm Solution based in EC2 instance on AWS.


The purpose of the Application Resource solution is to have a set of unified AWS services that will build applications in a single and direct way.


We've divided the code into distinct modules for better navigation and customization. The modules include:

- `EBS`: EBS sub-module for webfarms machines.
- `EC2`: EC2 sub-module for creating webfarms.
- `IAM-Policies_custom`: IAM sub-module for creating customized policies, where 3 policies are fixed in the definition module, 3 are inserted and are AWS policies and 1 or more policies are customized and attached to the same role.
- `IAM-Policies_managed`: IAM sub-module for using AWS managed policies.
- `IAM-Roles`: IAM sub-module for creating roles and instance profiles for ec2.
- `LB`: sub-module for creating a load balancer to be used by webfarms.
- `SecurityGroup\Custom`: SecurityGroup sub-module for creating SG with different rules and different CIDRs as needed.
- `SecurityGroup\webfarm-sg-http-80`: SecurityGroup sub-module for creating SG with the webfarms default port 80 fixed.


Keep in mind, this guide and the corresponding modules are continuously being improved. 

## Usage
Variables/locals are values ​​that are used several times in various parts of the code, it is recommended that these variables be declared at the top of the file.


### check the examples in below:

```hcl
variable "name" {
  type    = string
  default = "webfarm"
}
```

```hcl
###############################################################################################
#                                         IAM MODULE                                          #
###############################################################################################

// IAM-Role module
module "iam_roles" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Roles?ref=v0.0.1"

  name          = var.name

  tags_iam_role = { 
    Name        = var.name
  }
}

// IAM-Policies managed AWS
module "iam_policy_managed_sqs" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Policies_managed?ref=v0.0.1"
  depends_on = [ module.iam_roles ]

  policy_managed_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  role_attach_policy_managed_name = module.iam_roles.iam_role_name
}

module "iam_policy_managed_dynamodb" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Policies_managed?ref=v0.0.1"
  depends_on = [ module.iam_roles ]

  policy_managed_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role_attach_policy_managed_name = module.iam_roles.iam_role_name
}

// IAM-Policies managed yourself
module "iam_policy_ec2" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Policies_custom?ref=v0.0.1"
  depends_on = [ module.iam_roles ]

  policy_name        = "ec2_customized_policy"
  policy_description = "Custom policy to ec2 resources"
  policy_path        = "/"
  policy_document    = file("./json_policy/ec2_policy.json")
  role_attach_policy_managed_name = module.iam_roles.iam_role_name
}

module "iam_policy_s3" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/IAM-Policies_custom?ref=v0.0.1"
  depends_on = [ module.iam_roles ]

  policy_name        = "s3_customized_policy"
  policy_description = "Custom policy to S3 resources"
  policy_path        = "/"
  policy_document    = file("./json_policy/s3_policy.json")
  role_attach_policy_managed_name = module.iam_roles.iam_role_name
}
```
```hcl
###############################################################################################
#                                         SG MODULE                                           #
###############################################################################################

module "sg_http" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/SecurityGroup/webfarm-sg-http-80?ref=v0.0.1"

  name = "${var.name}-http-80"
  vpc_id  = "vpc-05fbbf774e5d5bf4c" 

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
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/SecurityGroup/Custom?ref=v0.0.1"

  name = "${var.name}-all-custom-1"
  vpc_id  = "vpc-05fbbf774e5d5bf4c"
  
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
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/SecurityGroup/Custom?ref=v0.0.1"

  name   = "${var.name}-all-custom-2"
  vpc_id  = "vpc-xxxxxxxxxxxxxxxxx"

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
```
```hcl
###############################################################################################
#                                         LB MODULE                                           #
###############################################################################################

module "alb" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/LB?ref=v0.0.1"
  depends_on = [ module.wf-instance-02 ]

  name    = "${var.name}-alb"
  vpc_id  = "vpc-05fbbf774e5d5bf4c"
  subnets = ["subnet-xxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxx"]
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
      target_id   = module.wf-instance-02.instance_id   // Obrigatorio target_id se for instance em target_type
    }
  }
// Fim Target Group
  tags = {
    "Environment" = "Dev"
  }
}



module "nlb_interno" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/LB?ref=v0.0.1"

  name    = "${var.name}-nlb-interno"
  vpc_id  = "vpc-xxxxxxxxxxxx"
  subnets = ["subnet-xxxxxxxxxxxx", "subnet-xxxxxxxxxxxx", "subnet-xxxxxxxxxxxx"]
  security_groups = [ module.sg_custom_1.sg_id ]

  load_balancer_type         = "network"
  enable_deletion_protection = false
  internal = true
  enable_cross_zone_load_balancing = true
  tags = {
    "Name" = "jfrog-artifactory-nlb"
    "Obs"  = "nlb-interno-jfrog"
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
    },
  }
  // Inicio Target Group
  target_groups = {
    // Primeiro targetgroup
    jfrog-artifactory-tg = {
      protocol    = "TCP"
      port        = 8082
      target_type = "instance"
      target_id   = module.wf-instance-01.instance_id    // Obrigatorio target_id
    }
  }
// Fim Target Group
}
```
```hcl
###############################################################################################
#                                         EC2 MODULE                                          #
###############################################################################################

# Instance standalone, windows, with adittional EBS Volume, without associate to ALB through target_group_arn variable, without instance profile association

module "wf-instance-01" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EC2?ref=v0.0.1"
  depends_on = [ module.sg_custom_1, module.sg_custom_2 ]

  name                   = "${var.name}-instance-01"
  ami_id                 = "ami-0c9890fb99eafa637" # Microsoft Windows Server 2019 Base
  os_instance             = "windows"
  key_name               = "key-webfarm-windows"
  
  instance_type          = "m5a.large"
  associate_public_ip    = false
  monitoring             = false
  vpc_security_group_ids = [ module.sg_custom_1.sg_id, module.sg_custom_2.sg_id ]

  tags = {
    "Name" = "${var.name}-instance-01"
  }
}

# Instance windows, with adittional EBS Volume, with association to ALB, with instance profile association

module "wf-instance-03" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EC2?ref=v0.0.1"
  depends_on = [ module.alb, module.sg_http, module.sg_custom_1 ]

  name                    = "${var.name}-instance-03"
  ami_id                  = "ami-0c9890fb99eafa637" # Microsoft Windows Server 019 Base
  #os_instance            = "windows"
  key_name                = "key-webfarm-windows"

  create_instance_profile = true
  iam_instance_profile    = "${var.name}_instance_profile-03"
  instance_type           = "m5a.large"
  associate_ec2_to_lb     = true
  target_group_arn        = module.alb.target_group_arn
  monitoring              = true
  vpc_security_group_ids  = [ module.sg_http.sg_id, module.sg_custom_1.sg_id ]

  tags = {
    "Name" = "${var.name}-instance-03"
  }
}

# Instance windows, with adittional EBS Volume, with association to ALB, with instance profile association
module "wf-instance-04" {
  source = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EC2?ref=v0.0.1"

  depends_on = [ module.sg_http, module.sg_custom_1, module.sg_custom_2, module.alb ]

  name                    = "${var.name}-instance-04"
  ami_id                  = "ami-0c9890fb99eafa637" # Microsoft Windows Server 2019 Base
  #os_instance             = "windows"
  key_name                = "key-webfarm-windows"

  create_instance_profile = true
  iam_instance_profile    = "${var.name}_instance_profile-04"
  instance_type           = "m5a.large"
  associate_ec2_to_lb     = true
  target_group_arn        = module.alb.target_group_arn
  monitoring              = true
  vpc_security_group_ids  = [ module.sg_http.sg_id, module.sg_http.sg_id, module.sg_custom_1.sg_id ]

  tags = {
    "Name" = "${var.name}-instance-04"
  }
}
```
```hcl
###############################################################################################
#                                         EBS MODULE                                          #
###############################################################################################

module "ebs_volumes_wf-instance-01" {
  source       = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EBS?ref=v0.0.1"

  instance_id  = module.wf-instance-01.instance_id
  depends_on = [ module.wf-instance-01 ]
  
  ebs_volumes = [
    {
      device_name          = "/dev/sdf"
      volume_size          = 20
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume1-nainstancia1"
      }
    },
    {
      device_name          = "/dev/sdg"
      volume_size          = 30
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume2-nainstancia1"
      }
    }
    // Adicione quantos volumes EBS adicionais desejar aqui
  ]
}


module "ebs_volumes_wf-instance-03" {
  source       = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EBS?ref=v0.0.1"

  instance_id  = module.wf-instance-03.instance_id
  depends_on = [ module.wf-instance-03 ]
  
  ebs_volumes = [
    {
      device_name          = "/dev/sdg"
      volume_size          = 50
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume1-nainstancia3"
      }
    }
    // Adicione quantos volumes EBS adicionais desejar aqui
  ]
}

module "ebs_volumes_wf-instance-04" {
  source       = "git::https://github.com/leosilvasouza/impacta-cloud-infrastructure-automation.git//modules/EBS?ref=v0.0.1"

  instance_id  = module.wf-instance-04.instance_id
  depends_on = [ module.wf-instance-04 ]
  
  ebs_volumes = [
    {
      device_name          = "/dev/sdf"
      volume_size          = 50
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume1-nainstancia4"
      }
    },
    {
      device_name          = "/dev/sdg"
      volume_size          = 60
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume2-nainstancia4"
      }
    },
    {
      device_name          = "/dev/sdh"
      volume_size          = 70
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume3-nainstancia4"
      }
    },        
    {
      device_name          = "/dev/sdi"
      volume_size          = 60
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume4-nainstancia4"
      }
    },
    {
      device_name          = "/dev/sdj"
      volume_size          = 70
      volume_type          = "gp2"
      iops                 = 100
      encrypted            = true
      final_snapshot       = false
      multi_attach_enabled = false
      tags        = {
        Name = "MeuVolume5-nainstancia4"
      }
    }       
    // Adicione quantos volumes EBS adicionais desejar aqui
  ]
}
```
## Notes

- `network_interface` can't be specified together with `vpc_security_group_ids`, `associate_public_ip_address`, `subnet_id`. See [complete example](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/tree/master/examples/complete) for details. If specify vpc_security_groups_ids, is necessary deactivate security_groups values.
- Changes in `ebs_block_device` argument will be ignored. Use [aws_volume_attachment](https://www.terraform.io/docs/providers/aws/r/volume_attachment.html) resource to attach and detach volumes from AWS EC2 instances. See [this example](https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/tree/master/examples/volume-attachment).
- `os_instance` must be specified obligatory because it is what the tag condition is used for for backups to take place.
-`associate_ec2_to_lb` must be used optionally when you want the ec2 that is being created to be associated with a target group of a load balancer that is being created.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.66 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.66 |


## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `string` | `null` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate a public IP address with an instance in a VPC | `bool` | `null` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | Determines whether an IAM instance profile is created or to use an existing IAM instance profile | `bool` | `false` | no |
| <a name="input_disable_api_stop"></a> [disable\_api\_stop](#input\_disable\_api\_stop) | If true, enables EC2 Instance Stop Protection | `bool` | `null` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `null` | no |
| <a name="volume_tags"></a> [volume\_tags](#volume\_tags) | Whether to enable volume tags (if enabled it conflicts with root\_block\_device tags) | `bool` | `true` | no |
| <a name="input_get_password_data"></a> [get\_password\_data](#input\_get\_password\_data) | If true, wait for password data to become available and retrieve it | `bool` | `null` | no |
| <a name="input_hibernation"></a> [hibernation](#input\_hibernation) | If true, the launched EC2 instance will support hibernation | `bool` | `null` | no |
| <a name="input_host_id"></a> [host\_id](#input\_host\_id) | ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | no |
| <a name="input_iam_role_policies"></a> [iam\_role\_policies](#input\_iam\_role\_policies) | Policies attached to the IAM role | `map(string)` | `{}` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role/profile created | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name` or `name`) is used as a prefix | `bool` | `true` | no |
| <a name="input_ignore_ami_changes"></a> [ignore\_ami\_changes](#input\_ignore\_ami\_changes) | Whether changes to the AMI ID changes should be ignored by Terraform. Note - changing this value will result in the replacement of the instance | `bool` | `false` | no |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instance | `string` | `null` | no |
| <a name="input_instance_tags"></a> [instance\_tags](#input\_instance\_tags) | Additional tags for the instance | `map(string)` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"t3.micro"` | no |
| <a name="input_ipv6_address_count"></a> [ipv6\_address\_count](#input\_ipv6\_address\_count) | A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet | `number` | `null` | no |
| <a name="input_ipv6_addresses"></a> [ipv6\_addresses](#input\_ipv6\_addresses) | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface | `list(string)` | `null` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource | `string` | `null` | no |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options of the instance | `map(string)` | <pre>{<br>  "http_endpoint": "enabled",<br>  "http_put_response_hop_limit": 1,<br>  "http_tokens": "optional"<br>}</pre> | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on EC2 instance created | `string` | `""` | no |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Customize network interfaces to be attached at instance boot time | `list(map(string))` | `[]` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC | `string` | `null` | no |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Customize details about the root block device of the instance. See Block Devices below for details | `list(any)` | `[]` | no |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs | `bool` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The VPC Subnet ID to launch in | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host | `string` | `null` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user\_data\_base64 instead | `string` | `null` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | Can be used instead of user\_data to pass base64-encoded binary data directly. Use this instead of user\_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | When used in combination with user\_data or user\_data\_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set | `bool` | `null` | no |
| <a name="volume_tags"></a> [volume\_tags](#volume\_tags) | A mapping of tags to assign to the devices created by the instance at launch time | `map(string)` | `{}` | no |
| <a name="vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#vpc\_security\_group\_ids) | A list of security group IDs to associate with | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami"></a> [ami](#output\_ami) | AMI ID that was used to create the instance |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the instance |
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | The availability zone of the created instance |
| <a name="output_ebs_block_device"></a> [ebs\_block\_device](#output\_ebs\_block\_device) | EBS block device information |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | ARN assigned by AWS to the instance profile |
| <a name="output_iam_instance_profile_id"></a> [iam\_instance\_profile\_id](#output\_iam\_instance\_profile\_id) | Instance profile's ID |
| <a name="output_iam_instance_profile_unique"></a> [iam\_instance\_profile\_unique](#output\_iam\_instance\_profile\_unique) | Stable and unique string identifying the IAM instance profile |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The Amazon Resource Name (ARN) specifying the IAM role |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | The name of the IAM role |
| <a name="output_iam_role_unique_id"></a> [iam\_role\_unique\_id](#output\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_id"></a> [id](#output\_id) | The ID of the instance |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | The state of the instance |
| <a name="output_ipv6_addresses"></a> [ipv6\_addresses](#output\_ipv6\_addresses) | The IPv6 address assigned to the instance, if applicable |
| <a name="output_outpost_arn"></a> [outpost\_arn](#output\_outpost\_arn) | The ARN of the Outpost the instance is assigned to |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | The ID of the instance's primary network interface |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP address assigned to the instance |
| <a name="output_root_block_device"></a> [root\_block\_device](#output\_root\_block\_device) | Root block device information |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |