# Pipeline de Infraestrutura (AWS + Terraform + GitHub Actions)

## Visão Geral

Uma visão rápida do fluxo da pipeline e do workflow da infraestrutura.

## Fluxo da Pipeline (exemplo)

![Fluxo da Pipeline](imgs/img.png)
*Figura 1: Diagrama do fluxo da pipeline (exemplo).* 

## Workflow da Pipeline

![Workflow da Pipeline](imgs/img_1.png)
*Figura 2: Workflow da pipeline mostrando triggers e etapas.*

## Como começar

1. Configure as secrets no GitHub: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` (usar `us-east-2`).
2. Proteja o Environment `production` antes de permitir o `apply` manual.
3. Para rodar localmente (dev):

```powershell
cd Infra
.\scripts\init-and-plan.ps1 -Env dev
```

## Documentação rápida
- Backend: `Infra/backend-dev.hcl` (usa o bucket existente e `us-east-2`).
- Variáveis: `Infra/envs/dev/terraform.tfvars` e `Infra/envs/prod/terraform.tfvars`.

## Cuidados importantes
- O backend do Terraform (S3 + DynamoDB para lock) armazena o state. NÃO altere os
  valores do backend (bucket/key/region) sem validar: mover o backend pode causar
  perda de acesso ao state ou criar estados duplicados.
- Os arquivos em `Infra/envs/*` contêm nomes literais de buckets/recursos. Alterações
  nesses arquivos devem ser feitas com revisão e, preferencialmente, em coordenação
  com a equipe responsável pelo ambiente.
- Em CI (GitHub Actions) a região e o bucket do backend são passados via inputs ao
  workflow e exportados como `TF_VAR_aws_region` e `TF_VAR_bucket_name` durante a execução.
- Ao rodar localmente, exporte `AWS_REGION` ou defina `TF_VAR_aws_region` e verifique
  que suas credenciais/role tenham permissão para acessar/criar o bucket (s3:CreateBucket,
  s3:ListBucket, s3:GetObject, s3:PutObject).

---

Desenvolvido por Build & Run
