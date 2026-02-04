output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Name of the S3 bucket created for Terraform state"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "ARN of the S3 bucket created for Terraform state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "Name of the DynamoDB table created for Terraform state locking"
}

output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.terraform_lock.arn
  description = "ARN of the DynamoDB table created for Terraform state locking"
}

output "backend_config" {
  value       = <<-EOT
    
    Backend configuration for Terraform:
    
    bucket         = "${aws_s3_bucket.terraform_state.id}"
    key            = "env/<environment>/Terraform-Infra-Pipeline/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${aws_dynamodb_table.terraform_lock.name}"
    encrypt        = true
    
    Add this to your backend.tf or use as -backend-config options.
  EOT
  description = "Backend configuration details"
}
