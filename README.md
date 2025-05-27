https://developer.hashicorp.com/terraform/language/backend/s3

Initialisation de l'infra

- Créer un user terraform (droit blabla)
- aws configure --profile "PROFILE_NAME"
- export AWS_PROFILE="PROFILE_NAME"
- Lancer le script. Il va ccréer le S3 pour le backend et un lock dynamoDB.
- Généré les fichiers de configuration backend.tf
