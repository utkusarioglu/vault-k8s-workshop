resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "web_app" {
  depends_on = [
    vault_auth_backend.approle
  ]
  role_name          = "web-app"
  token_policies     = ["web_app"]
  token_ttl          = 60 * 60
  token_max_ttl      = 4 * 60 * 60
  token_num_uses     = 3
  secret_id_num_uses = 5
  secret_id_ttl      = 60 * 60
}
