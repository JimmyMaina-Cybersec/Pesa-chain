#!/bin/bash

# Define the path where the policy files are located
POLICY_DIR="$HOME/Desktop/Pesa-chain/Security/Vault/vault-policies"

# Function to load policies from a given directory
load_policies() {
  local dir=$1
  echo "Loading policies from $dir..."

  # Loop over all .hcl files in the directory
  for policy_file in "$dir"/*.hcl; do
    policy_name=$(basename "$policy_file" .hcl)
    echo "Loading policy: $policy_name"
    vault policy write "$policy_name" "$policy_file"
  done
}

# Load policies from all directories
load_policies "$POLICY_DIR/Orderer"
load_policies "$POLICY_DIR/Org2"
load_policies "$POLICY_DIR/PesachainOrg"

echo "All policies have been loaded successfully!"
