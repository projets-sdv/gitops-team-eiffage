provider "kubernetes" {
  host = "https://kubernetes.default.svc"

  token                  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
  cluster_ca_certificate = file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
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
