# Provider AWS: a região é normalmente inferida por variável de ambiente ou TF_VAR_aws_region.
# No CI (GitHub Actions) definimos a região através do input `aws-region` e exportamos TF_VAR_aws_region.
# Para execução local recomendo: `export AWS_REGION=us-east-2` (Linux/macOS) ou
# no PowerShell: `$env:AWS_REGION = 'us-east-2'` antes de executar o Terraform.
provider "aws" {
  # region é inferida via variável de ambiente (AWS_REGION) definida no workflow/runner
}