# GitOps TODO-API

Repository GitOps du projet fil rouge TODO-API.

## Stack technique

- Kubernetes local avec k3d
- ArgoCD
- Argo Rollouts
- Kustomize
- GitHub Actions
- Terraform Controller
- Sealed Secrets / External Secrets

## Couverture des 5 étapes du projet

| Étape | Objectif | Implémentation |
|---|---|---|
| 1 | Fondations GitOps | ArgoCD déploie la todo-api depuis le repo GitOps |
| 2 | Multi-environnements | Kustomize avec dev, staging et prod |
| 3 | Déploiements progressifs | Argo Rollouts avec Rollout CRD |
| 4 | Infrastructure as Code | Flux Terraform Controller avec state Kubernetes |
| 5 | Sécurité | Sealed Secrets, RBAC et NetworkPolicy |

