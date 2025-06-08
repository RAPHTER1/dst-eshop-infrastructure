#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# Charge .env.local
set -a
source .env.local
set +a

# Exécute le playbook demandé (par défaut : 01-provision.yml)
PLAYBOOK=${1:-playbooks/01-provision.yml}

ansible-playbook "$PLAYBOOK" -i inventory/proxmox.yml
