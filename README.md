# AWS Secret Management Solution
- This solution leverages opensource SOPS (Secrets OPerationS)
- SOPS repository can be found here (https://github.com/getsops/sops)
- Visit this aritcle for more details https://medium.com/@my931uow/aws-secrets-management-with-terraform-and-sops-c13cef7c4069

## Prerequisites
- Terraform
- AWSCLI
- SOPS
- JQ

## Getting Started
# Encrypt your file

- SOPS encryptes your secrets using your AWS KMS key. Therefore, you will need to create a kms key before using this module

**Note: Update your .sops.yaml file before you encrypt your file**

```
# Export a required variable
export SOPS_KMS_ARN="$(aws resourcegroupstaggingapi get-resources --region us-east-1 --resource-type-filters kms --tag-filters Key=key_type,Values=sops | jq -r '.ResourceTagMappingList.[].ResourceARN')"

# Encrypt your json file
sops encrypt secrets.json > secrets.enc.json && rm secrets.json

# Checking the encrypted file
cat secrets.enc.json

"database_username": "ENC[AES256_GCM,data:M0yQG5oazoKYz5ZcEqU=,iv:0JLc5oPlAngfx5UqcfpwSFXkYipFEAflOgfXsYBecqI=,tag:Th9TLTqLFzpaMVDCsujZXQ==,type:str]",
"database_password": "ENC[AES256_GCM,data:62D8JePqLhncnRmSDs+kq0su,iv:FhywZezGYYO6UGDaIe/VPQaKi2/eg3S05O+117xlsnU=,tag:Pw6kzhJiejyfFIFmMKyeTQ==,type:str]"
.....
.....
```

# Update your file 
- You will be able to update your new or exisiting secrets

```
# Hit esc and :wq to update your secret
sops edit secrets.enc.json

```

# Deploy your updated secret via Terraform 
- AWS session needs to be alive

```
bash deployment.sh

# Expected output

🔐 Stage 1: Decrypting secrets...
✅ Secrets decrypted to temp file: /tmp/pipeline.secrets.json
🔧 Stage 2: Exporting secrets as Terraform variables...
📂 Stage 3: Listing current directory contents...
deployment.sh                   main.tf                         secrets.enc.json                terraform.tfstate
info.md                         README.md                       secrets.json                    terraform.tfstate.backup
🛠️ Stage 4: Checking Terraform version...
Terraform v1.11.4
on darwin_arm64
+ provider registry.terraform.io/hashicorp/aws v5.100.0

Your version of Terraform is out of date! The latest version
is 1.13.3. You can update by downloading from https://developer.hashicorp.com/terraform/install
📋 Stage 5: Running terraform plan...
aws_secretsmanager_secret.pipeline_secret: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx]
aws_secretsmanager_secret_version.pipeline_secretversion: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx|terraform-xxxxxx]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_secretsmanager_secret_version.pipeline_secretversion must be replaced
-/+ resource "aws_secretsmanager_secret_version" "pipeline_secretversion" {
      ~ arn                  = "arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx" -> (known after apply)
      + has_secret_string_wo = (known after apply)
      ~ id                   = "arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx|terraform-xxxxxx" -> (known after apply)
      ~ secret_string        = (sensitive value) # forces replacement
      ~ version_id           = "terraform-xxxxxx" -> (known after apply)
      ~ version_stages       = [
          - "AWSCURRENT",
        ] -> (known after apply)
        # (3 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply"
now.
✅ Plan succeeded.
🚀 Stage 6: Applying terraform changes...
aws_secretsmanager_secret.pipeline_secret: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx]
aws_secretsmanager_secret_version.pipeline_secretversion: Refreshing state... [id=arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx|terraform-xxxxxx]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_secretsmanager_secret_version.pipeline_secretversion must be replaced
-/+ resource "aws_secretsmanager_secret_version" "pipeline_secretversion" {
      ~ arn                  = "arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx" -> (known after apply)
      + has_secret_string_wo = (known after apply)
      ~ id                   = "arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx|terraform-xxxxxx" -> (known after apply)
      ~ secret_string        = (sensitive value) # forces replacement
      ~ version_id           = "terraform-xxxxxx" -> (known after apply)
      ~ version_stages       = [
          - "AWSCURRENT",
        ] -> (known after apply)
        # (3 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
aws_secretsmanager_secret_version.pipeline_secretversion: Destroying... [id=arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx|terraform-xxxxxx]
aws_secretsmanager_secret_version.pipeline_secretversion: Destruction complete after 0s
aws_secretsmanager_secret_version.pipeline_secretversion: Creating...
aws_secretsmanager_secret_version.pipeline_secretversion: Creation complete after 1s [id=arn:aws:secretsmanager:us-east-1:xxxxxx:secret:pipeline_secret-xxxxxx|terraform-xxxxxx]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
🧼 Stage 7: Cleanup will happen automatically via trap.
🎉 All stages completed successfully.
```
