provider "aws" {
  region = "us-east-1"
}

module "log_group" {
  source = "terraform-aws-modules/cloudwatch/aws//modules/log-group"

  name_prefix       = "my-log-group-"
  retention_in_days = 7
}

module "query_definition" {
  source = "terraform-aws-modules/cloudwatch/aws//modules/query-definition"

  name = "query-example"
  log_group_names = [
    module.log_group.cloudwatch_log_group_name
  ]
  query_string = <<EOF
fields @timestamp, @message
| sort @timestamp desc
| limit 25
EOF
}