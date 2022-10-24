artifacts_folder=artifacts
rm -rf $artifacts_folder
mkdir -p $artifacts_folder
for i in {0..2}; do
  sleep 3;
  echo "Starting unseal for 'vault-$i'…"
  artifact_file="$artifacts_folder/init.json"
  if [ "$i" == 0 ]; then
    if [ ! -f $artifact_file ] || [ -z "$(cat $artifact_file)" ]; then
      kubectl -n vault exec "vault-$i" -- vault operator init \
        -key-shares=5 \
        -key-threshold=3 \
        -format=json > \
        $artifact_file 
    fi
  fi
  if [ -z "$(cat $artifact_file)" ]; then
    echo "Error: Artifact file '$artifact_file' is empty"
    continue
  fi
  if [ "$i" != "0" ]; then
  echo "Joining $i to '0'…"
  kubectl -n vault exec "vault-$i" -- vault operator raft join http://vault-0.vault-internal:8200
  fi
  unseal_keys=$(jq -r '.unseal_keys_b64[0:3][]' $artifact_file)
  for key in $unseal_keys; do
    echo "vault-$i key $key"
    sleep 3;
    kubectl -n vault exec "vault-$i" -- vault operator unseal "$key"
  done
  if [ "$i" == 0 ]; then
    echo "Logging in '$i'…"
    root_token=$(jq -r '.root_token' $artifact_file)
    if [ -z "$root_token" ]; then 
      echo "Error: Root token is missing for $i"
      continue
    fi
    kubectl -n vault exec "vault-$i" -- vault login "$root_token"
  fi
  echo "Finished unseal for 'vault-$i'"
  echo
done
sleep 3;
for i in {0..2}; do
kubectl -n vault exec "vault-$i" -- vault status;
done
