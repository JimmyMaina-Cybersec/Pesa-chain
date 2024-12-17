#!/bin/bash

# Initialize Vault and store root token
vault operator init > vault-keys.txt

# Unseal Vault using the generated keys
for i in {1..3}; do
  KEY=$(grep "Unseal Key $i" vault-keys.txt | cut -d: -f2 | tr -d ' ')
  vault operator unseal $KEY
done

# Enable the KV secrets engine
vault secrets enable -path=pesachain kv-v2

# Create policies
vault policy write pesachain-admin vault/config/policies/admin-policy.hcl
vault policy write pesachain-ca vault/config/policies/ca-policy.hcl

# Store initial secrets
vault kv put pesachain/ca/admin \
  username="admin" \
  password="$(openssl rand -hex 24)"

vault kv put pesachain/auth0 \
  domain="${AUTH0_DOMAIN}" \
  client_id="${AUTH0_CLIENT_ID}" \
  client_secret="${AUTH0_CLIENT_SECRET}"

# Store TLS certificates
vault kv put pesachain/tls \
  cert="$(cat crypto-config/peerOrganizations/pesachain.com/ca/ca.pesachain.com-cert.pem)" \
  key="$(cat crypto-config/peerOrganizations/pesachain.com/ca/ca.pesachain.com-key.pem)" \
  ca="$(cat crypto-config/peerOrganizations/pesachain.com/ca/ca-chain.pem)"