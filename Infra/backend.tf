# Configuração do backend remoto (S3). O bloco fica vazio aqui e o comportamiento real
# é definido por arquivos `-backend-config` passados no `terraform init` (p.ex. através do workflow
# que fornece bucket, region e dynamodb_table).
# AVISO: não altere o backend local sem conhecimento — mudar o backend pode mover/duplicar o state.
terraform {
  backend "s3" {}
}


