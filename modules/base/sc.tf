# This module isn't used yet
resource "kubernetes_storage_class" "vault_sc" {
  metadata {
    name = "vault-sc"
  }
  # storage_provisioner = "local-path"
  storage_provisioner = "kubernetes.io/no-provisioner"
  reclaim_policy      = "Retain"
  # mount_options = [
  #   "file_mode=0700",
  #   "dir_mode=0777",
  #   "mfsymlinks",
  #   "uid=1000",
  #   "gid=1000",
  #   "nobrl",
  #   "cache=none"
  # ]
}
