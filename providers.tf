provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "k3d-${var.cluster_name}"
  }
  experiments {
    manifest = true
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-${var.cluster_name}"
}

# provider "vault" {
#   # It is strongly recommended to configure this provider through the
#   # environment variables:
#   #    - VAULT_ADDR
#   #    - VAULT_TOKEN
#   #    - VAULT_CACERT
#   #    - VAULT_CAPATH
#   #    - etc.
# }
