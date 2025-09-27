#! /bin/bash
set -euo pipefail

echo "🔐 Stage 1: Decrypting secrets..."
umask 077
TEMP_SECRET_FILE="$(mktemp /tmp/pipeline.secrets.json)"
ENCRYPTED_FILE=secrets.enc.json
export SOPS_KMS_ARN="$(aws resourcegroupstaggingapi get-resources --region us-east-1 --resource-type-filters kms --tag-filters Key=key_type,Values=sops | jq -r '.ResourceTagMappingList.[].ResourceARN')"
trap 'rm -f "$TEMP_SECRET_FILE"' EXIT

/opt/homebrew/bin/sops decrypt $ENCRYPTED_FILE > "$TEMP_SECRET_FILE"
echo "✅ Secrets decrypted to temp file: $TEMP_SECRET_FILE"

echo "🔧 Stage 2: Exporting secrets as Terraform variables..."

export TF_VAR_pipeline_secret="$(jq -c '(.data // .)' "$TEMP_SECRET_FILE")"

echo "📂 Stage 3: Listing current directory contents..."
ls

echo "🛠️ Stage 4: Checking Terraform version..."
terraform version

echo "📋 Stage 5: Running terraform plan..."
if terraform plan; then
  echo "✅ Plan succeeded."
  echo "🚀 Stage 6: Applying terraform changes..."
  terraform apply -auto-approve
else
  echo "❌ Plan failed. Skipping apply."
  exit 1
fi

echo "🧼 Stage 7: Cleanup will happen automatically via trap."
echo "🎉 All stages completed successfully."
unset TF_VAR_pipeline_secret
