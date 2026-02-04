# Data source para obter informações do bucket S3 configurado em `bucket_name`.
# Certifique-se que a variável `bucket_name` esteja correta (definida em envs/* ou via CI).
data "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}