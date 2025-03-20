provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "this" {
  length = 2
}

module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name                        = "my-table-${random_pet.this.id}"
  hash_key                    = "id"
  range_key                   = "title"
  table_class                 = "STANDARD"
  deletion_protection_enabled = false

  attributes = [
    {
      name = "id"
      type = "N"
    },
    {
      name = "title"
      type = "S"
    },
    {
      name = "age"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "TitleIndex"
      hash_key           = "title"
      range_key          = "age"
      projection_type    = "INCLUDE"
      non_key_attributes = ["id"]

      on_demand_throughput = {
        max_write_request_units = 1
        max_read_request_units  = 1
      }
    }
  ]

  on_demand_throughput = {
    max_read_request_units  = 1
    max_write_request_units = 1
  }

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }
}


module "disabled_dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  create_table = false
}