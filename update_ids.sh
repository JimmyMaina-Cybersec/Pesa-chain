#!/bin/bash
# update_secrets.sh
#
# This script reads the RoleID of each AppRole and writes the corresponding SecretID
# to the respective files in the specified directory.
#
# Requirements:
# - VAULT_ADDR and VAULT_TOKEN must be set in your environment.
# - For testing with self-signed certs, VAULT_SKIP_VERIFY may be set.

# (Optional) Skip TLS certificate verification for non-production environments
# export VAULT_SKIP_VERIFY=true

# Directory to store the credentials
CRED_DIR="$HOME/Desktop/Pesa-chain/Security/Vault/vault_creds"

# List of roles and corresponding files
declare -A roles_files=(
  ["orderer1-role"]="$CRED_DIR/orderer1-role_roleid.txt:$CRED_DIR/orderer1-role_secretid.txt"
  ["orderer2-role"]="$CRED_DIR/orderer2-role_roleid.txt:$CRED_DIR/orderer2-role_secretid.txt"
  ["orderer3-role"]="$CRED_DIR/orderer3-role_roleid.txt:$CRED_DIR/orderer3-role_secretid.txt"
  ["org2-admin-role"]="$CRED_DIR/org2-admin-role_roleid.txt:$CRED_DIR/org2-admin-role_secretid.txt"
  ["org2-certrenewalservice-role"]="$CRED_DIR/org2-certrenewalservice-role_roleid.txt:$CRED_DIR/org2-certrenewalservice-role_secretid.txt"
  ["org2-client1-role"]="$CRED_DIR/org2-client1-role_roleid.txt:$CRED_DIR/org2-client1-role_secretid.txt"
  ["org2-peer0-role"]="$CRED_DIR/org2-peer0-role_roleid.txt:$CRED_DIR/org2-peer0-role_secretid.txt"
  ["org2-peer1-role"]="$CRED_DIR/org2-peer1-role_roleid.txt:$CRED_DIR/org2-peer1-role_secretid.txt"
  ["pesachain-admin-role"]="$CRED_DIR/pesachain-admin-role_roleid.txt:$CRED_DIR/pesachain-admin-role_secretid.txt"
  ["pesachain-certrenewalservice-role"]="$CRED_DIR/pesachain-certrenewalservice-role_roleid.txt:$CRED_DIR/pesachain-certrenewalservice-role_secretid.txt"
  ["pesachain-client1-role"]="$CRED_DIR/pesachain-client1-role_roleid.txt:$CRED_DIR/pesachain-client1-role_secretid.txt"
  ["pesachain-peer0-role"]="$CRED_DIR/pesachain-peer0-role_roleid.txt:$CRED_DIR/pesachain-peer0-role_secretid.txt"
  ["pesachain-peer1-role"]="$CRED_DIR/pesachain-peer1-role_roleid.txt:$CRED_DIR/pesachain-peer1-role_secretid.txt"
)

# Function to update RoleID and SecretID
update_credentials() {
  local role="$1"
  local roleid_file="$2"
  local secretid_file="$3"

  # Get RoleID
  echo "Reading RoleID for $role..."
  roleid=$(vault read -field=role_id "auth/approle/role/$role/role-id")

  if [ -z "$roleid" ]; then
    echo "Error: RoleID for $role could not be retrieved"
    return
  fi

  # Save RoleID to file
  echo "$roleid" > "$roleid_file"
  echo "RoleID for $role saved to $roleid_file"

  # Generate SecretID and force write it
  echo "Creating SecretID for $role..."
  secretid=$(vault write -field=secret_id -force "auth/approle/role/$role/secret-id")

  if [ -z "$secretid" ]; then
    echo "Error: SecretID for $role could not be generated"
    return
  fi

  # Save SecretID to file
  echo "$secretid" > "$secretid_file"
  echo "SecretID for $role saved to $secretid_file"
}

# Loop through each role and update the credentials
for role in "${!roles_files[@]}"; do
  # Split the file paths (RoleID file and SecretID file)
  IFS=":" read -r roleid_file secretid_file <<< "${roles_files[$role]}"
  update_credentials "$role" "$roleid_file" "$secretid_file"
done

echo "All credentials have been updated successfully!"
