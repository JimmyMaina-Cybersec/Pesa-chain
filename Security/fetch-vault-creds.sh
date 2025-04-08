#!/bin/bash

# Create the vault-creds folder if it doesn't exist
mkdir -p vault-creds

# Define the list of roles
roles=(
  "orderer1-role"
  "orderer2-role"
  "orderer3-role"
  "org2-admin-role"
  "org2-certrenewalservice-role"
  "org2-client1-role"
  "org2-peer0-role"
  "org2-peer1-role"
  "pesachain-admin-role"
  "pesachain-certrenewalservice-role"
  "pesachain-client1-role"
  "pesachain-peer0-role"
  "pesachain-peer1-role"
)

# Loop over each role and fetch its credentials
for role in "${roles[@]}"; do
  echo
  echo "Processing role: $role"
  sleep 1

  # Retrieve the role_id from Vault
  role_id_response=$(vault read -format=json "auth/approle/role/${role}/role-id")
  if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve role_id for ${role}"
    continue
  fi
  role_id=$(echo "$role_id_response" | jq -r '.data.role_id')

  # Retrieve the secret_id from Vault
  secret_id_response=$(vault write -format=json -f "auth/approle/role/${role}/secret-id")
  if [ $? -ne 0 ]; then
    echo "Error: Failed to generate secret_id for ${role}"
    continue
  fi
  secret_id=$(echo "$secret_id_response" | jq -r '.data.secret_id')

  # Save the role_id and secret_id to files
  echo "$role_id" > "vault-creds/${role}_roleid.txt"
  echo "$secret_id" > "vault-creds/${role}_secretid.txt"
done

echo "Vault credentials have been stored in the 'vault-creds' folder."
