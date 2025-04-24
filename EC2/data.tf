data "aws_vpcs" "all" {}
 
# Select the first VPC 
data "aws_vpc" "selected" {
  id = data.aws_vpcs.all.ids[0]
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
}

# Select the first subnet 
data "aws_subnet" "selected" {
  id = data.aws_subnets.all.ids[0]
}

data "aws_ami" "red_hat" {
  most_recent = true
  owners = ["172862522320"]

  filter {
    name   = "name"
    values = ["rhel* 2024-*"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_availability_zones" "available" {}

#############################################################

# data "aws_ami_id" "selected"{
#     id = data.aws_ami_ids.red_hat.ids[0]
# }
