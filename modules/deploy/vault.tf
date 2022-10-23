resource "helm_release" "vault" {
  name            = "vault"
  repository      = "https://helm.releases.hashicorp.com"
  chart           = "vault"
  version         = "0.22.0"
  namespace       = "vault"
  cleanup_on_fail = true
  lint            = true

  values = [
    yamlencode({
      global = {
        enabled    = true
        tlsDisable = true
      }
      server = {
        dataStorage = {
          enabled = true
          # mountPath = "/volumes/vault"
        }
        auditStorage = {
          enabled = true
        }
        ha = {
          enabled  = true
          replicas = 3
          raft = {
            enabled   = true
            setNodeId = true
            config    = <<-EOF
              ui = true

              listener "tcp" {
                address     = "[::]:8200"
                cluster_address = "[::]:8201"
                tls_disable = 1
              }

              storage "raft" {
                path = "/vault/data"
                setNodeId = true

                retry_join {
                  leader_api_addr = "https://vault-0.vault-internal.vault:8200"
                }

                retry_join {
                  leader_api_addr = "https://vault-1.vault-internal.vault:8200"
                }

                retry_join {
                  leader_api_addr = "https://vault-2.vault-internal.vault:8200"
                }

                autopilot {
                  cleanup_dead_servers = "true"
                  last_contact_threshold = "200ms"
                  last_contact_failure_threshold = "10m"
                  max_trailing_logs = 250000
                  min_quorum = 3
                  server_stabilization_time = "10s"
                }
              }

              service_registration "kubernetes" {}
            EOF
          }
        }
      }

      injector = {
        enabled = true
      }

      ui = {
        enabled         = true
        serviceType     = "LoadBalancer"
        serviceNodePort = null
        externalPort    = 8200
      }
    })
  ]
}
