resource "kubernetes_namespace" "this" {
  for_each = toset(["vault", "k8s-dashboard"])

  metadata {
    name = each.key
  }
}
