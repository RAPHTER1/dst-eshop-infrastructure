#!/bin/bash

set -e

AWS_TERRAFORM_PROFILE="terraform"
AWS_REGION="eu-west-3"
BUCKET_NAME="eshop-tf-state"
DYNAMO_TABLE_NAME="eshop-tf-lock"

if [[ -z "$AWS_PROFILE" ]]; then
    echo -e "AWS_PROFILE n'est pas défini."
    echo "Veuillez exécuter : export AWS_PROFILE"
    exit 1
fi

echo -e "Utilisation du profil AWS: $AWS_PROFILE"

# Création du bucket S3
echo -e "Vérification du bucket S3 [$BUCKET_NAME]..."

if ! aws s3api head-bucket --bucket "$BUCKET_NAME" >/dev/null 2>&1; then
    echo -e "Création du bucket S3 [$BUCKET_NAME]..."
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$AWS_REGION" \
        --create-bucket-configuration LocationConstraint="$AWS_REGION"
else
    echo -e "Le bucket [$BUCKET_NAME] existe déjà."
fi

# === Création de la table DynamoDB ===

echo -e "Vérification de la table DynamoDB [$DYNAMO_TABLE_NAME]..."

if aws dynamodb describe-table --table-name "$DYNAMO_TABLE_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
    echo -e "Création de la table DynamoDB [$DYNAMO_TABLE_NAME]..."
    aws dynamodb create-table \
        --table-name "$DYNAMO_TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,AttributeType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $AWS_REGION

else
    echo -e "La table DynamoDB [$DYNAMO_TABLE_NAME] existe déjà."
fi

echo -e "Backend Terraform prêt."

# === Génération des fichier backend.tf ===
echo -e "Génération des fichiers backend.tf ..."

for env in $(ls terraform/environments); do
    cat >"terraform/environments/$env/backend.tf" <<EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "$env/terraform.tfstate"
    region         = "$AWS_REGION"
    dynamodb_table = "$DYNAMO_TABLE_NAME"
  }
}
EOF
    echo "Fichier backend.tf généré pour l'environnement $env"
done
