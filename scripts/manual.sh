rm -rf artifacts
mkdir -p artifacts
for i in 0 1 2; do
  echo "Starting unseal for 'vault-$i'…"
  artifact_file="artifacts/init.$i.json"
  kubectl -n vault exec "vault-$i" -- vault operator init \
    -key-shares=5 \
    -key-threshold=3 \
    -format=json > \
    $artifact_file 
  if [ -z "$(cat artifacts/init.$i.json)" ]; then
    echo "Artifact file '$artifact_file' is empty"
    continue
  fi
  unseal_keys=$(jq -r '.unseal_keys_b64[0:3][]' $artifact_file)
  for key in $unseal_keys; do
    kubectl -n vault exec "vault-$i" -- vault operator unseal $key
  done
  echo "Finished unseal for 'vault-$i'"
done
