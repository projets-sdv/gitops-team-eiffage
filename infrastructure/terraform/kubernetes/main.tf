provider "kubernetes" {
  in_cluster_config = true
}

resource "kubernetes_namespace" "todo_api_infra" {
  metadata {
    name = "todo-api-infra"

    labels = {
      managed-by = "terraform-controller"
      project    = "todo-api"
    }
  }
}

resource "kubernetes_service_account" "todo_api_automation" {
  metadata {
    name      = "todo-api-automation"
    namespace = kubernetes_namespace.todo_api_infra.metadata[0].name

    labels = {
      managed-by = "terraform-controller"
      project    = "todo-api"
    }
  }
}

resource "kubernetes_config_map" "todo_api_global_config" {
  metadata {
    name      = "todo-api-global-config"
    namespace = kubernetes_namespace.todo_api_infra.metadata[0].name

    labels = {
      managed-by = "terraform-controller"
      project    = "todo-api"
    }
  }

  data = {
    APP_NAME          = "todo-api"
    DEPLOYMENT_MODEL  = "gitops"
    CI_TOOL           = "github-actions"
    CD_TOOL           = "argocd"
    PROGRESSIVE_DELIVERY = "argo-rollouts"
  }
}

resource "kubernetes_resource_quota" "todo_api_quota" {
  metadata {
    name      = "todo-api-resource-quota"
    namespace = kubernetes_namespace.todo_api_infra.metadata[0].name
  }

  spec {
    hard = {
      "pods"            = "10"
      "requests.cpu"    = "2"
      "requests.memory" = "2Gi"
      "limits.cpu"      = "4"
      "limits.memory"   = "4Gi"
    }
  }
}

resource "kubernetes_limit_range" "todo_api_limits" {
  metadata {
    name      = "todo-api-limit-range"
    namespace = kubernetes_namespace.todo_api_infra.metadata[0].name
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = "500m"
        memory = "512Mi"
      }

      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
}
