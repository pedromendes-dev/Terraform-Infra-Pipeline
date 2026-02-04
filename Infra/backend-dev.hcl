# Configuração de backend para ambiente de desenvolvimento.
# AVISO: este arquivo contém o bucket e key usados como backend remoto do Terraform.
# Alterar estes valores pode mover/duplicar o state ou causar perda de acesso.
# Use com cuidado e somente após verificar se o bucket/key existem e têm permissão adequada.
bucket = "pedromendes-dev-us-east-2-tarraform-statefile"
key    = "env/dev/Terraform-Infra-Pipeline/terraform.tfstate"
region = "us-east-2"
encrypt = true
