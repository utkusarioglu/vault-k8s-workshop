kubectl -n vault exec vault-0 -- vault audit enable file \
  file_path=/vault/audit/vault_audit.log

kubectl -n vault exec vault-0 -- vault auth enable approle

kubectl -n vault exec vault-0 -- sh -c "cat << EOF > /vault/web-app.policy.hcl 
path \"secrets/data/mysql/web-app\" {
  capabilities = [ \"read\" ]
}
EOF"

kubectl -n vault exec vault-0 -- vault policy write \
  web_app \
  /vault/web-app.policy.hcl

kubectl -n vault exec vault-0 -- vault secrets enable -path secrets kv

kubectl -n vault exec vault-0 -- vault write \
  secrets/data/mysql/web-app \
  db_name=wp-data \
  db_user=wordpress \
  db_pass=pass1

kubectl -n vault exec vault-0 -- vault write auth/approle/role/web-app \
  token_policies=web_app \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_num_uses=5 \
  token_num_uses=3
