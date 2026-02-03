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

---

Desenvolvido por Build & Run
