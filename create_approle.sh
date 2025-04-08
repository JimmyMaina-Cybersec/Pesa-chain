#!/bin/bash
# create_approles.sh
#
# This script iterates over the policy files in the specified directories
# and creates an AppRole for each one in Vault.
#
# Requirements:
# - VAULT_ADDR and VAULT_TOKEN must be set in your environment.
# - For testing with self-signed certs, VAULT_SKIP_VERIFY may be set.

# (Optional) Skip TLS certificate verification for non-production environments
# export VAULT_SKIP_VERIFY=true

# Base directory where your policy files are stored
POLICY_DIR="$HOME/Desktop/Pesa-chain/Security/Vault/vault-policies"

# Function to create an AppRole based on a policy file
create_role() {
  local policy_file="$1"
  # Get the base filename, e.g. "org2-peer1-policy" from "org2-peer1-policy.hcl"
  local policy_full=$(basename "$policy_file" .hcl)
  # Remove the "-policy" suffix to get the clean policy name
  local policy=${policy_full%-policy}
  # Create a role name by appending "-role" to the policy name
  local role_name="${policy}-role"

  echo "Creating AppRole '$role_name' with token policy '$policy'..."
  vault write auth/approle/role/"${role_name}" \
    token_policies="${policy}" \
    token_ttl=1h \
    token_max_ttl=4h
}

# Loop through each subdirectory (Orderer, Org2, PesachainOrg)
for dir in "$POLICY_DIR"/*/; do
  echo "Processing policies in directory: $dir"
  for policy_file in "$dir"/*.hcl; do
    # If there are no .hcl files, skip the loop
    [ -e "$policy_file" ] || continue
    create_role "$policy_file"
  done
done

echo "All AppRoles have been created successfully!"
