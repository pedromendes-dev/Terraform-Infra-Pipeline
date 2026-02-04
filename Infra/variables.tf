# Nome do bucket S3 usado como backend do Terraform (armazenamento do state).
# AVISO: não altere este valor em produção a menos que saiba o que está fazendo.
# É normalmente definido por arquivo de variáveis em Infra/envs/* ou por CI (TF_VAR_bucket_name).
variable "bucket_name" {
  type = string
}

# Região AWS usada pelo provider e pelo backend.
# OBS: o workflow exporta TF_VAR_aws_region a partir do input `aws-region`.
# Se rodar localmente, exporte AWS_REGION ou defina TF_VAR_aws_region antes de executar o Terraform.
variable "aws_region" {
  type        = string
  description = "Região AWS a ser usada pelo provedor e pelo backend"
  default     = "us-east-2"
}
