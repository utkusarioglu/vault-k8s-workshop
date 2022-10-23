resource "kubernetes_namespace" "vault" {
  count = 1
  metadata {
    name = "vault"
  }
}
