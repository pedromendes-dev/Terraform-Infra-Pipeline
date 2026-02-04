# Guia de Bootstrap - Resolver Erro de Backend do Terraform

## 🎯 Problema

O workflow do GitHub Actions está falando com o seguinte erro:

```
O bucket 'pedromendes-dev-us-east-2-tarraform-statefile' não existe ou não está acessível;
AVISO: criação automática de bucket está desabilitada (input allow-create-bucket != true).
```

### Por que isso acontece?

O Terraform precisa de:
1. **Bucket S3** - Para armazenar o state (estado da infraestrutura)
2. **Tabela DynamoDB** - Para lock do state (evitar conflitos entre múltiplas execuções)

Estes recursos precisam existir **ANTES** do Terraform poder usá-los como backend. Isso cria um problema de "galinha e ovo": o Terraform precisa do backend para funcionar, mas o backend não existe ainda.

## ✅ Solução

Existem 4 formas de resolver este problema:

### 1. 🚀 Via GitHub Actions (MAIS FÁCIL - RECOMENDADO)

Esta é a forma mais simples e não requer configuração local.

**Passos:**
1. Vá para o repositório no GitHub
2. Clique na aba **"Actions"**
3. No menu lateral esquerdo, selecione **"Bootstrap Backend (S3 + DynamoDB)"**
4. Clique no botão **"Run workflow"** (canto superior direito)
5. Revise os valores padrão:
   - AWS Region: `us-east-2`
   - S3 Bucket Name: `pedromendes-dev-us-east-2-tarraform-statefile`
   - DynamoDB Table Name: `pedromendes-dev-us-east-2-terraform-lock`
6. Clique em **"Run workflow"** verde
7. Aguarde a conclusão (≈ 2 minutos)

✅ Pronto! Agora você pode re-executar o workflow que estava falhando.

---

### 2. 💻 Via Script Local

Se você tem o repositório clonado localmente e AWS CLI configurado:

```bash
cd bootstrap
./bootstrap.sh
```

O script irá:
- ✓ Verificar se AWS CLI e Terraform estão instalados
- ✓ Verificar suas credenciais AWS
- ✓ Mostrar o plano de mudanças
- ✓ Pedir sua confirmação
- ✓ Criar os recursos na AWS

---

### 3. 🔧 Via Terraform Local (Avançado)

Para desenvolvedores que querem mais controle:

```bash
cd bootstrap
terraform init
terraform plan    # Revise as mudanças
terraform apply   # Confirme com 'yes'
```

---

### 4. 🖱️ Via AWS Console (Manual)

Se preferir criar manualmente pela interface da AWS:

**Criar o Bucket S3:**
1. Vá para o serviço S3 no AWS Console
2. Clique em "Create bucket"
3. Nome: `pedromendes-dev-us-east-2-tarraform-statefile`
4. Região: `US East (Ohio)` / `us-east-2`
5. Em "Bucket Versioning": Selecione **"Enable"**
6. Em "Default encryption": Selecione **"Server-side encryption with Amazon S3 managed keys (SSE-S3)"**
7. Em "Block Public Access": Deixe todas as 4 opções **marcadas** (bloquear acesso público)
8. Clique em "Create bucket"

**Criar a Tabela DynamoDB:**
1. Vá para o serviço DynamoDB no AWS Console
2. Clique em "Create table"
3. Nome da tabela: `pedromendes-dev-us-east-2-terraform-lock`
4. Partition key: `LockID` (tipo: **String**)
5. Configurações da tabela: Selecione **"On-demand"** (billing mode)
6. Clique em "Create table"

---

## 📋 Recursos Criados

Após executar o bootstrap, os seguintes recursos existirão na sua conta AWS:

### Bucket S3: `pedromendes-dev-us-east-2-tarraform-statefile`
- **Região**: us-east-2
- **Versionamento**: Habilitado (permite recuperar versões antigas do state)
- **Criptografia**: SSE-S3 (AES256)
- **Acesso público**: Bloqueado (segurança)
- **Propósito**: Armazenar o arquivo de state do Terraform

### Tabela DynamoDB: `pedromendes-dev-us-east-2-terraform-lock`
- **Região**: us-east-2
- **Chave primária**: `LockID` (String)
- **Billing mode**: PAY_PER_REQUEST (você paga apenas pelo uso)
- **Propósito**: Gerenciar locks do state (evitar que múltiplas execuções do Terraform modifiquem o state simultaneamente)

---

## 🎉 Após o Bootstrap

Depois de executar o bootstrap com sucesso:

1. ✅ O bucket S3 e a tabela DynamoDB existem
2. ✅ Os workflows do GitHub Actions funcionarão normalmente
3. ✅ Você pode executar o Terraform localmente
4. ✅ O state será armazenado remotamente e compartilhado

### Re-executar o Workflow

- **Para produção (branch main)**: Faça um novo commit ou re-execute o workflow manualmente
- **Para dev (branch develop)**: O workflow deve funcionar automaticamente no próximo push

---

## 🔒 Permissões Necessárias

A role/usuário IAM usado precisa das seguintes permissões:

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
        "s3:PutBucketPublicAccessBlock"
      ],
      "Resource": "arn:aws:s3:::pedromendes-dev-us-east-2-tarraform-statefile"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable"
      ],
      "Resource": "arn:aws:dynamodb:us-east-2:*:table/pedromendes-dev-us-east-2-terraform-lock"
    }
  ]
}
```

---

## ❓ Troubleshooting

### Erro: "Access Denied"
**Causa**: Suas credenciais não têm as permissões necessárias.
**Solução**: Peça ao administrador da conta AWS para conceder as permissões acima.

### Erro: "BucketAlreadyExists"
**Causa**: O nome do bucket já está em uso (namespace global do S3).
**Solução**: Escolha um nome diferente modificando as variáveis no workflow/script.

### Erro: "Region not specified"
**Causa**: A região AWS não foi configurada.
**Solução**: Configure `AWS_REGION=us-east-2` ou passe via parâmetro.

---

## 📚 Mais Informações

- Documentação detalhada: [`bootstrap/README.md`](bootstrap/README.md)
- README principal: [`readme.md`](readme.md)
- Configuração do bootstrap: [`bootstrap/`](bootstrap/)

---

## 🗑️ Remover Recursos (Cuidado!)

Se você precisar destruir os recursos criados:

```bash
cd bootstrap
terraform destroy
```

⚠️ **AVISO**: Isso apagará o bucket S3 e a tabela DynamoDB. Certifique-se de fazer backup do state do Terraform antes de fazer isso!

---

**Dúvidas?** Consulte a [documentação do Terraform](https://www.terraform.io/docs/language/settings/backends/s3.html) sobre backend S3.
