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

kubectl -n vault exec vault-0 -- vault write auth/approle/role/web-app \
  token_policies=web_app \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_num_uses=5 \
  token_num_uses=3

kubectl -n vault exec vault-0 -- vault read \
  -format=json \
  auth/approle/role/web-app/role-id > \
  artifacts/web-app.role-id.json

kubectl -n vault exec vault-0 -- vault write \
  -format=json \
  -force \
  auth/approle/role/web-app/secret-id > \
  artifacts/web-app.secret-id.json

kubectl -n vault exec vault-0 -- vault secrets enable -path secrets kv

kubectl -n vault exec vault-0 -- vault write \
  secrets/data/mysql/web-app \
  db_name=wp-data \
  db_user=wordpress \
  db_pass=pass1

kubectl -n vault exec vault-1 -- vault write \
  -format=json \
  auth/approle/login \
  role_id="$(jq -r .data.role_id artifacts/web-app.role-id.json)" \
  secret_id="$(jq -r .data.secret_id artifacts/web-app.secret-id.json)" > \
  artifacts/web-app.login.json

for attempt in {1..5}; do
  echo "Attempt $attempt"
  if [ $attempt -gt 3 ]; then
    echo "This one should fail"
  fi
  kubectl -n vault exec vault-1 -- sh -c "\
    VAULT_TOKEN=\"$(jq -r .auth.client_token artifacts/web-app.login.json)\" \
    vault read \
    -format=json \
    secrets/data/mysql/web-app \
  "
  echo
done


kubectl -n vault get po -o=json | jq '.items[] | select(.metadata.name|test("^vault-[0-9]")) | .metadata.name'
