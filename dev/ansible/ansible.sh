#!/bin/bash

# On se place dans le dossier du script
cd "$(dirname "$0")"

echo "Lancement du playbook Ansible provision_cluster.yml"
echo "Dossier courant : $(pwd)"

# Chargement des variables d'environnement locales si le fichier existe
if [ -f ".env.local" ]; then
  echo "Chargement des variables depuis .env.local"
  export $(grep -v '^#' .env.local | xargs)
else
  echo "Fichier .env.local non trouvé, certaines variables pourraient manquer."
fi

# Lancement du playbook principal
ansible-playbook playbooks/provision_cluster.yml -i inventory/proxmox.yml "$@" # "$@" permet de passer des arguments au script

# Résultat
if [ $? -eq 0 ]; then
  echo "Provisionnement terminé avec succès"
else
  echo "Échec du provisionnement"
  exit 1
fi