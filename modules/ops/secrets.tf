resource "vault_kv_secret" "mysql_web_app" {
  path      = "${vault_mount.secrets.path}/mysql/web-app"
  data_json = file("assets/secrets/mysql-web-app.secret.json")
}
