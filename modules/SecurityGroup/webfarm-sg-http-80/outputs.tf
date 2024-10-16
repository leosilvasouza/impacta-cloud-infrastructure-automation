output "sg_name" {
  description = "The name of the security group"
  value = module.webfarm-sg-http-80.sg_name
}

output "sg_id" {
  description = "The ID of the security group"
  value = module.webfarm-sg-http-80.sg_id
}

output "sg_arn" {
  description = "The ARN of the security group"
  value = module.webfarm-sg-http-80.sg_arn
}