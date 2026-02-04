# IAM policy para GitHub Actions (Terraform)

Este diretório contém uma policy exemplo para a role assumida pelo GitHub Actions ao executar o workflow do Terraform.

Instruções rápidas:
1. Substitua os placeholders no arquivo `github-actions-terraform-policy.json` por valores reais:
   - `<BUCKET_NAME>`: nome do bucket S3 (ou use `arn:aws:s3:::*` se preferir aplicar a múltiplos buckets).
   - `<REGION>` e `<ACCOUNT_ID>`: região e account id AWS.
   - `<DYNAMODB_TABLE_NAME>`: nome da tabela DynamoDB usada para lock.
   - `<KMS_KEY_ARN_OR_*>`: ARN da chave KMS ou `*` se não utilizar KMS.
2. Crie uma role no AWS IAM e anexe essa policy (ou uma versão controlada/limitada dela).
3. Configure o input `aws-assume-role-arn` do workflow para apontar para a role criada.

Permissões mínimas recomendadas:
- s3:GetObject, s3:PutObject, s3:ListBucket, s3:CreateBucket (se usar allow-create-bucket), s3:PutBucketVersioning.
- dynamodb:GetItem, dynamodb:PutItem, dynamodb:CreateTable (para criar se necessário).
- kms:Encrypt/Decrypt se o bucket usar KMS.

Segurança:
- Prefira limitar os resources (ARNs) em vez de usar `*`.
- Para PRs de forks, GitHub não expõe secrets; o workflow que utilize a role deve estar protegido e rodar apenas em branches confiáveis ou via dispatch manual.
