# Ansible Role: setup_microk8s

Ce rôle installe et configure MicroK8s sur une machine Ubuntu, et, si le rôle est exécuté dans un contexte CI (GitLab), génère un fichier `kubeconfig` spécifique pour GitLab CI/CD, puis le pousse en tant que variable de projet via l’API GitLab.

---

## 📦 Fonctions principales

- Installation et configuration de MicroK8s (via le rôle parent).
- Création d’un ServiceAccount `gitlab-ci` dans le namespace `kube-system`.
- Extraction sécurisée du token de ce ServiceAccount.
- Récupération du certificat d’autorité de MicroK8s (`ca.crt`).
- Génération dynamique d’un `kubeconfig` dédié à GitLab CI.
- Encodage du `kubeconfig` en base64.
- Mise à jour (ou création) de la variable `KUBECONFIG_GITLAB_B64` dans le projet GitLab, uniquement si le contenu a changé.

---

## 🚀 Variables d’environnement nécessaires

- `GITLAB_API_TOKEN` : jeton privé GitLab avec accès à l’API.
- `CI_PROJECT_ID` : identifiant du projet GitLab.
- `K8S_API_PUBLIC_URL` : URL publique de l’API K8s (ex: `https://X.X.X.X:9101`).

---

## 🧠 Idempotence assurée par :

- Le module `kubernetes.core.k8s` qui applique les manifests sans recréer les objets existants.
- Génération locale du `kubeconfig` suivie d’une **comparaison avec la version encodée déjà poussée sur GitLab** (via l’API).
- La variable GitLab n’est mise à jour **que si le contenu a changé**, assurant ainsi un comportement idempotent même lors de relances du pipeline.

---

## 📂 Fichiers requis

- `templates/kubeconfig_gitlab.yml.j2` : template Jinja2 du kubeconfig GitLab.
- `files/gitlab_sa.yaml` : manifest Kubernetes du ServiceAccount GitLab CI.

---

## 🔁 Utilisation

Dans votre playbook principal :

```yaml
- name: Installer et paramétrer MicroK8s
  include_role:
    name: setup_microk8s
```

Ce rôle détectera automatiquement s’il s’exécute dans un environnement CI grâce à :

```yaml
- name: Include CI-specific tasks
  import_tasks: ci.yml
  when: lookup('env', 'CI') == 'true'
```

---

## 🔐 Sécurité

- Le token est masqué (`no_log: true`).
- Le kubeconfig est stocké temporairement (`/tmp/`) et encodé avant envoi.

---

## 🔧 Dépendances

Ce rôle dépend de la collection `kubernetes.core` et `community.general` d'Ansible **et** du module Python `kubernetes` **installé sur la machine qui exécute Ansible** (typiquement : votre runner GitLab ou votre poste de travail).

### 📦 Installation de la collection (machine de contrôle)

```bash
ansible-galaxy collection install kubernetes.core
```

### 🐍 Installation du module Python `kubernetes` (machine de contrôle)

Le module doit être accessible par le binaire Python utilisé par Ansible (défini dans `ansible_python_interpreter`).

#### ✅ Recommandé : installation dans l’environnement utilisateur

```bash
python3 -m pip install --user kubernetes
export PATH="$HOME/.local/bin:$PATH"
```

#### 💡 Alternative : via pipx (environnement isolé)

```bash
apt install -y pipx
pipx ensurepath
pipx install kubernetes
```

#### ⚠️ Alternative moins conseillée : installation système (Debian 12+)

```bash
apt install -y python3-kubernetes
```

⚠️ Cela installe une version packagée souvent plus ancienne.

#### 🚨 En dernier recours : contournement de l’environnement protégé

Uniquement dans un environnement contrôlé (VM, conteneur, CI jetable), et **en toute connaissance de cause** :

```bash
python3 -m pip install kubernetes --break-system-packages
```

❗ Cette méthode contourne la protection PEP 668 et peut corrompre votre environnement Python système. **À éviter sur un système de production ou partagé.**

---

## 📤 Résultats attendus (Outputs)

- Un ServiceAccount `gitlab-ci` présent dans `kube-system`.
- Un `kubeconfig` généré dans `/tmp/kubeconfig_gitlab.yml` (ou en local si `delegate_to: localhost`).
- Une variable `KUBECONFIG_GITLAB_B64` disponible dans GitLab (section `Settings > CI/CD > Variables`), encodée en base64.
- Aucune tâche relancée inutilement lors des exécutions suivantes (si rien n’a changé).

---

## ✅ Exemple de succès dans CI

```text
TASK [setup_microk8s : Apply Gitlab CI ServiceAccount manifest] => changed
TASK [setup_microk8s : Get GitLab CI SA token] => ok
TASK [setup_microk8s : Write kubeconfig if content differs or file is missing] => changed
TASK [setup_microk8s : Push GitLab project variable] => changed
```

Vérifiez ensuite dans GitLab :

1. Menu > Settings > CI/CD > Variables
2. Vérifiez que `KUBECONFIG_GITLAB_B64` est présent
3. Testez un job CI avec `KUBECONFIG` injecté automatiquement

---

## 📌 Remarque

Ce rôle est conçu pour être utilisé dans un workflow GitLab CI **avec MicroK8s installé localement** sur un hôte Ubuntu. Le `kubeconfig` généré est destiné à permettre à GitLab CI d’interagir avec ce cluster.

Le module Python `kubernetes` n’a pas besoin d’être installé sur les machines cibles — uniquement sur la machine qui exécute les playbooks Ansible.
