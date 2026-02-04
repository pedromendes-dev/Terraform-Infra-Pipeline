variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-east-2"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for Terraform state. Must be globally unique and follow S3 naming rules (lowercase, 3-63 chars, only a-z, 0-9, -, .)"
  default     = "pedromendes-dev-us-east-2-tarraform-statefile"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table for Terraform state locking"
  default     = "pedromendes-dev-us-east-2-terraform-lock"
}
