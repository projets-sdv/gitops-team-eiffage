provider "kubernetes" {
  config_path = "/tmp/kubeconfig"
}

resource "kubernetes_namespace" "todo_api_managed" {
  metadata {
    name = "todo-api-managed"
    labels = {
      managed-by = "terraform-controller"
      project    = "todo-api"
    }
  }
}
