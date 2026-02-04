<#
PowerShell script de exemplo para criar uma role IAM para GitHub Actions usando OIDC.
Este script assume que você tem AWS CLI configurado localmente e permissões para criar provider/role/policy.

Substitua os placeholders antes de executar: <ACCOUNT_ID>, <ROLE_NAME>, <POLICY_ARN>, <OWNER>, <REPO>
#>

param(
  [string]$AccountId = "559050205686",
  [string]$RoleName = "GitHubActions-Terraform-Role",
  [string]$PolicyArn = "arn:aws:iam::559050205686:policy/GitHubActions-Terraform-Policy",
  [string]$Owner = "pedromendes-dev",
  [string]$Repo = "Terraform-Infra-Pipeline"
)

Write-Host "Verificando se o OIDC provider do GitHub Actions já existe..."
$provider_url = "token.actions.githubusercontent.com"
$existing = aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[].Arn' --output text 2>$null | Select-String -Pattern $provider_url -Quiet
if ($existing) {
  Write-Host "OIDC provider já existe."
} else {
  Write-Host "Criando OIDC provider token.actions.githubusercontent.com..."
  aws iam create-open-id-connect-provider --url https://token.actions.githubusercontent.com --client-id-list sts.amazonaws.com --thumbprint-list ") || true
}

# Criar trust policy substituindo placeholders
$trust = Get-Content -Raw -Path "./Infra/iam/gh-trust-policy-example.json"
$trust = $trust -replace "<ACCOUNT_ID>", $AccountId
$trust = $trust -replace "<OWNER>", $Owner
$trust = $trust -replace "<REPO>", $Repo
$tempFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempFile -Value $trust -Encoding UTF8

Write-Host "Criando role $RoleName com trust policy..."
aws iam create-role --role-name $RoleName --assume-role-policy-document file://$tempFile

Write-Host "Anexando policy $PolicyArn a role $RoleName..."
aws iam attach-role-policy --role-name $RoleName --policy-arn $PolicyArn

Write-Host "Limpeza..."
Remove-Item $tempFile -Force
Write-Host "Pronto. Role criada: $RoleName (anexada policy: $PolicyArn)"
