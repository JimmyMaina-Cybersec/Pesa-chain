#!/bin/bash

# List of target template file paths
files=(
  "vault-tmpl/orderer2/orderer2-signcert.ctmpl"
  "vault-tmpl/orderer2/orderer2-prvKey.ctmpl"
  "vault-tmpl/orderer2/orderer2-srvCert.ctmpl"
  "vault-tmpl/orderer2/orderer2-srvKey.ctmpl"
  "vault-tmpl/orderer2/orderer2-ca.ctmpl"
  "vault-tmpl/orderer3/orderer3-signcert.ctmpl"
  "vault-tmpl/orderer3/orderer3-prvKey.ctmpl"
  "vault-tmpl/orderer3/orderer3-srvCert.ctmpl"
  "vault-tmpl/orderer3/orderer3-srvKey.ctmpl"
  "vault-tmpl/orderer3/orderer3-ca.ctmpl"
)

# Path to your generic template file
generic_template="generic.ctmpl"

# Loop through each file path
for item in "${files[@]}"; do
  # Create the parent directory for the file if it doesn't exist
  mkdir -p "$(dirname "$item")"
  # Copy the generic template into the file
  cp "$generic_template" "$item"
done

echo "All directories and template files have been created."
