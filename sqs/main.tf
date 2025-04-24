provider "aws" {
  region = local.region
  profile = "new-account"
}

data "aws_caller_identity" "current" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-east-1"

  tags = {
    Name       = local.name
    Example    = "complete"
    Repository = "github.com/terraform-aws-modules/terraform-aws-sqs"
  }
}

################################################################################
# SQS Module
################################################################################

module "default_sqs" {
  source = "terraform-aws-modules/sqs/aws"

  name = "${local.name}-default"

  tags = local.tags
}

module "fifo_sqs" {
  source = "terraform-aws-modules/sqs/aws"

  # `.fifo` is automatically appended to the name
  # This also means that `use_name_prefix` cannot be used on FIFO queues
  name       = local.name
  fifo_queue = true

  # Dead letter queue
  create_dlq = true
  redrive_policy = {
    # default is 5 for this module
    maxReceiveCount = 10
  }

  tags = local.tags
}

module "unencrypted_sqs" {
  source = "terraform-aws-modules/sqs/aws"

  name                    = "${local.name}-unencrypted"
  sqs_managed_sse_enabled = false

  tags = local.tags
}

module "cmk_encrypted_sqs" {
  source = "terraform-aws-modules/sqs/aws"

  name            = "${local.name}-cmk"
  use_name_prefix = true

  kms_master_key_id                 = aws_kms_key.this.id
  kms_data_key_reuse_period_seconds = 3600

  # Dead letter queue
  create_dlq = true
  redrive_policy = {
    # default is 5 for this module
    maxReceiveCount = 10
  }

  tags = local.tags
}

module "sse_encrypted_sqs" {
  source = "terraform-aws-modules/sqs/aws"

  name                    = "${local.name}-sse"
  sqs_managed_sse_enabled = true

  # Dead letter queue
  redrive_policy = {
    deadLetterTargetArn = module.sse_encrypted_dlq_sqs.queue_arn
    maxReceiveCount     = 10
  }

  tags = local.tags
}

module "sse_encrypted_dlq_sqs" {
  source = "terraform-aws-modules/sqs/aws"

  # This is a separate queue used as a dead letter queue for the above example
  # instead of the module creating both the queue and dead letter queue together

  name                    = "${local.name}-sse-dlq"
  sqs_managed_sse_enabled = true

  # Dead letter queue
  dlq_redrive_allow_policy = {
    sourceQueueArns = [module.sse_encrypted_sqs.queue_arn]
  }

  tags = local.tags
}

module "sqs_with_dlq" {
  source = "terraform-aws-modules/sqs/aws"

  # This creates both the queue and the dead letter queue together

  name = "${local.name}-sqs-with-dlq"

  # Policy
  # Not required - just showing example
  create_queue_policy = true
  queue_policy_statements = {
    account = {
      sid = "AccountReadWrite"
      actions = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      ]
    }
  }

  # Dead letter queue
  create_dlq = true
  redrive_policy = {
    # default is 5 for this module
    maxReceiveCount = 10
  }
  create_dlq_redrive_allow_policy = false

  # Dead letter queue policy
  # Not required - just showing example
  create_dlq_queue_policy = true
  dlq_queue_policy_statements = {
    account = {
      sid = "AccountReadWrite"
      actions = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      ]
    }
  }

  tags = local.tags
}

module "disabled_sqs" {
  source = "terraform-aws-modules/sqs/aws"

  create = false
}

################################################################################
# Supporting resources
################################################################################

resource "aws_kms_key" "this" {}