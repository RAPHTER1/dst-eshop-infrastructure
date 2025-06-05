#!/bin/bash

set -euo pipefail

# Fichier JSON de définition des VMs
JSON_FILE="./scripts/kubernetes.json"

# Clé publique envoyée via variable d'environnement
if [ -z "${K8S_PROXMOX_PUBLIC_KEY:-}" ]; then
  echo "ERREUR : la variable K8S_PROXMOX_PUBLIC_KEY est vide ou absente."
  exit 2
fi

# Vérifie que jq est installé
if ! command -v jq >/dev/null 2>&1; then
  echo "jq est requis. Installez-le avec : apt install jq"
  exit 2
fi

# Fonction de parsing
get_vm_info() {
  local index="$1"
  jq -r ".[$index] | to_entries | map(\"\(.key)=\(.value | @sh)\") | .[]" "$JSON_FILE"
}

# TODO: Ajouter une vérification ici pour s'assurer que toutes les variables nécessaires sont bien définies
# Exemple futur :
# VARS=(VM_ID VM_NAME ...) ; for var in "${VARS[@]}"; do if [ -z "${!var:-}" ]; then echo "$var manquante"; exit 1; fi; done

# Stockage de toutes les infos dans un tableau bash
JSON_OUTPUT="["

# Nombre total de VMs dans le fichier
TOTAL=$(jq length "$JSON_FILE")
echo "$TOTAL VM(s) à créer depuis $JSON_FILE"

for i in $(seq 0 $((TOTAL - 1))); do
  eval "$(get_vm_info "$i")"

  echo "Création de la VM $VM_NAME (ID $VM_ID)..."

  # Vérification du nom
  if [[ "$VM_NAME" =~ [^a-z0-9-] ]]; then
    echo "Nom invalide : $VM_NAME. Utilisez uniquement a-z, 0-9 et -"
    continue
  fi

  # Clone du template
  if ! qm clone $TEMPLATE_ID $VM_ID --name $VM_NAME 2>&1 | tee /tmp/clone_$VM_ID.log; then
    if grep -q "already exists" /tmp/clone_$VM_ID.log; then
      echo "VM $VM_ID existe déjà."
    else
      echo "Échec du clonage pour VM $VM_ID"
      exit 1
    fi
  fi

  # Resize du disque si nécessaire
  if qm config $VM_ID | grep -q '^scsi0:'; then
    qm disk resize $VM_ID scsi0 $DISK_SIZE || echo "Erreur resize disque"
  else
    echo "Aucun scsi0 détecté pour resize"
  fi

  # Configuration des ressources et réseau
  qm set $VM_ID \
    --memory $VM_MEMORY \
    --cores $VM_CPU \
    --net0 virtio,bridge=$BRIDGE

  # IP fixe via cloud-init
  qm set $VM_ID --ipconfig0 ip=$VM_IP_CIDR,gw=$GATEWAY

  # Clé SSH injectée temporairement via un fichier
  TMP_KEY=$(mktemp)                             # Créer un fichier temporaire vide
  echo "$K8S_PROXMOX_PUBLIC_KEY" > "$TMP_KEY"   # Ecriture du contenue de la variable d'environnement dans le fichier temporaire
  qm set $VM_ID --sshkey "$TMP_KEY"
  rm -f "$TMP_KEY"                              # On supprime le ficher temporaire

  # Démarrage de la VM
  qm start $VM_ID
  echo "VM $VM_NAME (ID $VM_ID) démarrée avec IP $VM_IP_CIDR"
  echo "--------------------------------------------"

  #JSON OUTPUT pour Ansible
  VM_IP_ONLY=$(echo "$VM_IP_CIDR" | cut -d'/' -f1)
  JSON_OUTPUT+='{"vm_name":"'"$VM_NAME"'","vm_ip":"'"$VM_IP_ONLY"'"},'

done

# Enlevé la virgule final
JSON_OUTPUT="${JSON_OUTPUT%,}"

# Écrire le tableau JSON complet dans un fichier
echo "[$JSON_OUTPUT]" > tmp/provisioned_vms.json

echo "Toutes les VMs ont été traitées."