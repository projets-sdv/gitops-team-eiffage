# GitOps TODO API – Team Eiffage

## Présentation du projet

Ce projet a été réalisé dans le cadre du Projet Fil Rouge DevOps.

L'objectif est de construire une plateforme GitOps complète autour d'une application TODO API conteneurisée en utilisant les pratiques modernes du Cloud Native :

- Kubernetes
- GitOps
- ArgoCD
- Argo Rollouts
- Flux Terraform Controller
- Kustomize
- GitHub Actions
- GitHub Container Registry (GHCR)
- Sealed Secrets
- RBAC
- Network Policies

L'application est déployée automatiquement sur Kubernetes à partir d'un dépôt GitOps versionné sur GitHub.

---

# Architecture globale

```text
Développeur
     │
     ▼
GitHub (todo-api)
     │
     ▼
GitHub Actions
     │
     ├── Tests
     ├── Build Docker
     ├── Push GHCR
     └── Mise à jour du dépôt GitOps
                    │
                    ▼
       GitHub (gitops-team-eiffage)
                    │
                    ▼
                ArgoCD
                    │
                    ▼
              Kubernetes
                    │
     ┌──────────────┼──────────────┐
     ▼              ▼              ▼
    DEV          STAGING         PROD

                    │
                    ▼
            Argo Rollouts
                    │
                    ▼
      Canary Deployment

                    │
                    ▼
        Terraform Controller
                    │
                    ▼
        Infrastructure as Code
```

---

# Structure du dépôt

```text
gitops-team-eiffage/

├── apps/
│   └── todo-api/
│       ├── base/
│       │   ├── configmap.yaml
│       │   ├── namespace.yaml
│       │   ├── rollout.yaml
│       │   ├── service.yaml
│       │   └── kustomization.yaml
│       │
│       └── overlays/
│           ├── dev/
│           ├── staging/
│           └── prod/
│
├── argocd/
│   └── applications/
│       ├── todo-api-dev.yaml
│       ├── todo-api-staging.yaml
│       └── todo-api-prod.yaml
│
├── infrastructure/
│   └── terraform/
│       ├── gitrepository.yaml
│       ├── namespace.yaml
│       ├── rbac.yaml
│       ├── terraform.yaml
│       └── kubernetes/
│           ├── main.tf
│           └── versions.tf
│
├── security/
│   ├── sealed-ghcr-secret-dev.yaml
│   ├── rbac.yaml
│   └── networkpolicy.yaml
│
└── README.md
```

---

# Technologies utilisées

| Technologie | Utilisation |
|------------|-------------|
| Kubernetes | Orchestration des conteneurs |
| K3D | Cluster Kubernetes local |
| ArgoCD | Déploiement GitOps |
| Argo Rollouts | Déploiements progressifs |
| Flux Terraform Controller | Infrastructure as Code GitOps |
| Terraform | Provisionnement des ressources |
| Kustomize | Gestion des environnements |
| GitHub Actions | CI/CD |
| GHCR | Registry Docker |
| Sealed Secrets | Gestion sécurisée des secrets |
| RBAC | Contrôle d'accès Kubernetes |
| Network Policies | Sécurisation réseau |

---

# Déploiement GitOps

Le déploiement est entièrement piloté par Git.

Toute modification du dépôt GitOps déclenche automatiquement :

1. Détection du changement par ArgoCD
2. Synchronisation des manifests Kubernetes
3. Déploiement de la nouvelle version
4. Réconciliation automatique de l'état du cluster

---

# Gestion des environnements

Trois environnements sont déployés :

| Environnement | Réplicas |
|--------------|----------|
| Development | 1 |
| Staging | 2 |
| Production | 3 |

Chaque environnement possède son propre overlay Kustomize.

---

# Pipeline CI/CD

Le pipeline GitHub Actions réalise automatiquement les étapes suivantes :

## 1. Exécution des tests unitaires

```bash
pytest
```

## 2. Construction de l'image Docker

```bash
docker build
```

## 3. Publication dans GHCR

```bash
docker push ghcr.io
```

## 4. Mise à jour du dépôt GitOps

Le pipeline modifie automatiquement :

```text
apps/todo-api/base/rollout.yaml
```

avec le nouveau tag de l'image Docker.

## 5. Déploiement automatique

ArgoCD détecte la modification du dépôt GitOps et déclenche automatiquement la synchronisation.

---

# Déploiements progressifs

Le projet utilise Argo Rollouts.

## Canary Deployment

Les nouvelles versions sont déployées progressivement afin de :

- réduire le risque lors des mises en production ;
- observer le comportement de la nouvelle version ;
- permettre un rollback rapide en cas de problème.

Le Rollout remplace le Deployment Kubernetes classique.

---

# Infrastructure as Code

L'infrastructure est gérée par Flux Terraform Controller.

Les ressources Terraform sont stockées dans :

```text
infrastructure/terraform/
```

Terraform est exécuté directement dans Kubernetes.

Le state Terraform est stocké dans le cluster Kubernetes.

La réconciliation est automatique.

Exemple de ressource créée :

```text
Namespace : todo-api-managed
```

---

# Sécurité

## Sealed Secrets

Les secrets sont chiffrés avant d'être stockés dans Git.

Fichier utilisé :

```text
security/sealed-ghcr-secret-dev.yaml
```

---

## RBAC

Des rôles Kubernetes limitent les permissions accordées aux applications.

Validation réalisée :

```text
get pods      -> autorisé
delete pods   -> refusé
```

Principe appliqué :

```text
Least Privilege
```

---

## Network Policies

Les communications réseau sont limitées aux flux explicitement autorisés.

Objectifs :

- réduction de la surface d'attaque ;
- isolation des workloads ;
- sécurisation des échanges inter-pods.

---

# Validation du projet

## Validation ArgoCD

```bash
kubectl get applications -A
```

Résultat obtenu :

```text
todo-api-dev       Synced   Healthy
todo-api-staging   Synced   Healthy
todo-api-prod      Synced   Healthy
```

---

## Validation Argo Rollouts

```bash
kubectl get rollouts -A
```

Résultat obtenu :

```text
todo-api-dev       Available
todo-api-staging   Available
todo-api-prod      Available
```

---

## Validation Terraform Controller

```bash
kubectl get terraform -n infra-system
```

Résultat obtenu :

```text
READY   True
STATUS  No drift
```

---

## Validation Sealed Secrets

```bash
kubectl get sealedsecret -A
```

Résultat obtenu :

```text
SYNCED True
```

---

## Validation RBAC

```bash
kubectl auth can-i get pods \
--as=system:serviceaccount:todo-api-dev:todo-api-sa \
-n todo-api-dev
```

Résultat :

```text
yes
```

```bash
kubectl auth can-i delete pods \
--as=system:serviceaccount:todo-api-dev:todo-api-sa \
-n todo-api-dev
```

Résultat :

```text
no
```

---

# Couverture des 5 étapes du projet

| Étape | Description | Statut |
|---------|-------------|---------|
| Étape 1 | Fondations GitOps avec ArgoCD | ✅ |
| Étape 2 | Multi-environnements et CI/CD GitOps | ✅ |
| Étape 3 | Déploiements progressifs avec Argo Rollouts | ✅ |
| Étape 4 | Infrastructure as Code avec Terraform Controller | ✅ |
| Étape 5 | Sécurité GitOps (Sealed Secrets, RBAC, Network Policies) | ✅ |

---

# Résultats obtenus

Le projet permet :

- Déploiement automatique via GitOps ;
- Gestion multi-environnements ;
- Déploiements progressifs sécurisés ;
- Infrastructure pilotée par Git ;
- Gestion sécurisée des secrets ;
- Contrôle d'accès Kubernetes ;
- Réconciliation automatique du cluster ;
- Pipeline CI/CD entièrement automatisé.

L'ensemble des objectifs du projet fil rouge a été implémenté et validé avec succès.
