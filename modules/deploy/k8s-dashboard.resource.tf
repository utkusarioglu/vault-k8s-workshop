resource "helm_release" "k8s_dashboard" {
  count             = 1
  repository        = "https://kubernetes.github.io/dashboard"
  chart             = "kubernetes-dashboard"
  name              = "kubernetes-dashboard"
  version           = "5.11.0"
  namespace         = "k8s-dashboard"
  dependency_update = true
  atomic            = true
}

resource "kubernetes_service_account" "k8s_dashboard" {
  count = 1

  metadata {
    name      = "admin-user"
    namespace = "k8s-dashboard"
  }

  depends_on = [
    helm_release.k8s_dashboard[0]
  ]
}

resource "kubernetes_cluster_role_binding" "k8s_dashboard" {
  count = 1

  metadata {
    name = "admin-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = "k8s-dashboard"
  }

  depends_on = [
    helm_release.k8s_dashboard[0],
    kubernetes_service_account.k8s_dashboard[0]
  ]
}
