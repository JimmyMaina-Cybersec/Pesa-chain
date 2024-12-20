#!/bin/bash

# Initialize Vault and store root token
vault operator init > ../vault/vault-keys.txt

# Unseal Vault using the generated keys
for i in {1..3}; do
  KEY=$(grep "Unseal Key $i" ../vault/vault-keys.txt | cut -d: -f2 | tr -d ' ')
  vault operator unseal $KEY
done

# Enable the KV secrets engine
vault secrets enable -path=pesachain kv-v2

# Store initial secrets
vault kv put pesachain/ca/admin \
  username="admin" \
  password="$(openssl rand -hex 24)"

vault kv put pesachain/auth0 \
  domain="${AUTH0_DOMAIN}" \
  client_id="${AUTH0_CLIENT_ID}" \
  client_secret="${AUTH0_CLIENT_SECRET}" \
  client_audience="${AUTH0_CLIENT_AUDIENCE}"

# Store TLS certificates
vault kv put pesachain/tls \
  cert="$(cat crypto-config/peerOrganizations/pesachain.com/ca/ca.pesachain.com-cert.pem)" \
  key="$(cat crypto-config/peerOrganizations/pesachain.com/ca/ca.pesachain.com-key.pem)" \
  ca="$(cat crypto-config/peerOrganizations/pesachain.com/ca/ca-chain.pem)"