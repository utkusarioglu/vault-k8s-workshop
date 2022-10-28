# Create admin policy in the root namespace
resource "vault_policy" "admin_policy" {
  name   = "admin"
  policy = file("assets/policies/admin-policy.hcl")
}

# Create 'training' policy
resource "vault_policy" "eaas-client" {
  name   = "eaas-client"
  policy = file("assets/policies/eaas-client-policy.hcl")
}

resource "vault_policy" "web_app" {
  name   = "web_app"
  policy = file("assets/policies/web-app.policy.hcl")
}
