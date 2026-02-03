variable "bucket_name" {
  type = string
}

variable "aws_region" {
  type        = string
  description = "AWS region to use for provider and backend"
  default     = "sa-east-1"
}
