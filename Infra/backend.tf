# Configuração do backend remoto (S3). O bloco fica vazio aqui e o comportamiento real
# é definido por arquivos `-backend-config` passados no `terraform init` (p.ex. através do workflow
# que fornece bucket, region e dynamodb_table).
#
# Notas importantes:
# - Usamos S3 para armazenar o state do Terraform e DynamoDB para lock (evita concorrência).
# - Requisitos do bucket S3: nomes em minúsculas, 3-63 caracteres, apenas a-z, 0-9, '-' e '.'.
# - Em CI, o workflow `.github/workflows/terraform.yml` injeta o bucket, region e dynamodb_table
#   via `-backend-config` durante o `terraform init`.
# - Se estiver configurando manualmente: crie o bucket S3 com versioning habilitado e políticas
#   que permitam operações necessárias (GetObject, PutObject, ListBucket). A role usada no CI
#   precisa de permissões adicionais para criar buckets se `allow-create-bucket` for true.
# - Evite alterar o backend de produção sem um plano claro; mover o backend pode criar estados
#   duplicados ou perda de acesso.

terraform {
  backend "s3" {}
}
