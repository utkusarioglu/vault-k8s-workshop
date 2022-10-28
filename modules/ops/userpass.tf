resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "student" {
  depends_on = [
    vault_auth_backend.userpass
  ]
  path                 = "auth/userpass/users/utkusarioglu"
  ignore_absent_fields = true

  data_json = <<-EOT
  {
    "policies": ["admins", "eaas-client"],
    "password": "pass1"
  }
  EOT
}
