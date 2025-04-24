provider "aws" {
  region = local.region
  profile = "new-account"
}

locals {
  name   = "example-${basename(path.cwd)}"
  region = "us-east-1"
  vpc_id = data.aws_vpc.selected.id
  ami_id = data.aws_ami.red_hat.id

  #ami_id = "ami-0d2555c8599b5e3ab"
  #vpc_cidr = "10.0.0.0/16"

  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  
  tags = {
    Name       = local.name
    Example    = local.name
  }
}

################################################################################
# EC2 Module
################################################################################

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.name

  ami                         = local.ami_id
  instance_type               = "t2.micro"
  availability_zone           = element(local.azs, 0)
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = false

  tags = local.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = data.aws_vpc.selected.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

#################################################################################

# resource "aws_volume_attachment" "this" {
#   device_name = "/dev/sdh"
#   volume_id   = aws_ebs_volume.this.id
#   instance_id = module.ec2.id
# }

# resource "aws_ebs_volume" "this" {
#   availability_zone = module.ec2.availability_zone
#   size              = 1

#   tags = local.tags
# }

################################################################################
# Supporting Resources
################################################################################

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 4.0"

#   name = local.name
#   cidr = local.vpc_cidr

#   azs             = local.azs
#   private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
#   public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

#   tags = local.tags
# }

# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }


