# Terraform Backend Bootstrap

Este diretório contém a configuração necessária para criar a infraestrutura de backend do Terraform antes de usar a configuração principal.

## O que isso faz?

Este bootstrap cria:

1. **Bucket S3** (`pedromendes-dev-us-east-2-tarraform-statefile`) - Para armazenar o state do Terraform
   - Versionamento habilitado
   - Criptografia habilitada (AES256)
   - Acesso público bloqueado

2. **Tabela DynamoDB** (`pedromendes-dev-us-east-2-terraform-lock`) - Para lock de state (evitar conflitos)
   - Billing mode: PAY_PER_REQUEST
   - Hash key: LockID

## Por que isso é necessário?

O Terraform precisa de um backend remoto (S3 + DynamoDB) para:
- Armazenar o state de forma compartilhada
- Permitir que múltiplos usuários/pipelines trabalhem com a mesma infraestrutura
- Prevenir conflitos com state locking

No entanto, esses recursos precisam ser criados **antes** de configurar o backend remoto. Este é o problema clássico de "galinha e ovo" (chicken-and-egg).

## Como usar

### Opção 1: Script automatizado (recomendado)

```bash
cd bootstrap
./bootstrap.sh
```

O script irá:
1. Verificar se AWS CLI e Terraform estão instalados
2. Verificar suas credenciais AWS
3. Mostrar um plano das mudanças
4. Pedir confirmação
5. Criar os recursos

### Opção 2: Comandos manuais

```bash
cd bootstrap

# Inicializar Terraform
terraform init

# Ver o plano
terraform plan

# Aplicar (criar os recursos)
terraform apply

# Ver os outputs com informações dos recursos criados
terraform output
```

### Customizar nomes (opcional)

Você pode customizar os nomes usando variáveis de ambiente:

```bash
export AWS_REGION="us-east-2"
export BUCKET_NAME="meu-bucket-customizado"
export DYNAMODB_TABLE="minha-tabela-customizada"
./bootstrap.sh
```

Ou passando variáveis diretamente ao Terraform:

```bash
terraform apply \
  -var="aws_region=us-east-2" \
  -var="bucket_name=meu-bucket" \
  -var="dynamodb_table_name=minha-tabela"
```

## Pré-requisitos

1. **AWS CLI** instalado e configurado
2. **Terraform** instalado (versão >= 1.0)
3. **Credenciais AWS** com permissões para:
   - Criar buckets S3
   - Configurar políticas de bucket S3
   - Criar tabelas DynamoDB

### Permissões IAM necessárias

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:PutBucketVersioning",
        "s3:PutEncryptionConfiguration",
        "s3:PutBucketPublicAccessBlock",
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::pedromendes-dev-us-east-2-tarraform-statefile"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:TagResource"
      ],
      "Resource": "arn:aws:dynamodb:us-east-2:*:table/pedromendes-dev-us-east-2-terraform-lock"
    }
  ]
}
```

## Depois do bootstrap

Depois de executar o bootstrap com sucesso:

1. Os recursos S3 e DynamoDB estarão criados
2. Você pode executar a configuração principal do Terraform em `../Infra`
3. Os workflows do GitHub Actions funcionarão corretamente
4. O state do Terraform será armazenado remotamente no S3

## Estado do bootstrap

⚠️ **Importante**: O bootstrap usa backend **local** (não remoto) para evitar o problema de galinha e ovo. O state do bootstrap ficará em `bootstrap/terraform.tfstate`.

**Recomendações:**
- Faça backup deste arquivo se precisar destruir os recursos depois
- Considere armazenar este state em um local seguro (repositório privado ou S3 separado)
- Para ambientes de produção, considere criar esses recursos manualmente via AWS Console

## Destruir recursos (cuidado!)

Se você precisar destruir os recursos criados pelo bootstrap:

```bash
cd bootstrap
terraform destroy
```

⚠️ **AVISO**: Isso irá destruir o bucket S3 e a tabela DynamoDB. Certifique-se de que não há estados do Terraform importantes armazenados no bucket antes de fazer isso!

## Troubleshooting

### Erro: "BucketAlreadyExists"
O nome do bucket já está em uso. Escolha um nome diferente usando a variável `bucket_name`.

### Erro: "Access Denied"
Suas credenciais AWS não têm permissões suficientes. Verifique as permissões IAM acima.

### Erro: AWS CLI não encontrado
Instale o AWS CLI: https://aws.amazon.com/cli/

### Erro: Terraform não encontrado
Instale o Terraform: https://www.terraform.io/downloads
