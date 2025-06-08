#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# Génère l'inventaire final
envsubst < inventory/proxmox.template.yml > inventory/proxmox.yml
echo "Inventaire généré : inventory/proxmox.yml"

# Charge .env.local
set -a
source .env.local
set +a

# Génère l'inventaire
./generate_inventory.sh

# Exécute le playbook demandé (par défaut : 01-provision.yml)
PLAYBOOK=${1:-playbooks/01-provision.yml}

ansible-playbook "$PLAYBOOK" -i inventory/proxmox.yml
