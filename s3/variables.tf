variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-1"
}


variable "tag_name" {
    description = "Tag Name"
    type = string
    default = "dev"
}

variable "tag_env" {
    description = "Tag Environment"
    type = string
    default = "test_env"
}   