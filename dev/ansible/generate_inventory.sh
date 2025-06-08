#!/bin/bash
set -e

# Charge toutes les variables d'environnement du fichier local
set -a
source .env.local
set +a

# Génère l'inventaire final
envsubst < inventory/proxmox.template.yml > inventory/proxmox.yml
echo "Inventaire généré : inventory/proxmox.yml"
