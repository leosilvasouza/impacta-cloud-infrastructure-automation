module "webfarm-sg-http-80" {
# checkov:skip=CKV_AWS_23: The description is created like variable to attach in each rule. 

  source = "../Custom"

  name   = var.name
  vpc_id = var.vpc_id
  tags   = var.tags

  # This values default is declared here because this sub-module is called
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks = var.egress_with_cidr_blocks
}