#!/bin/bash

set -e
set -o pipefail

source init-vault.sh

# Retry a command a given number of times
retry_command() {
    local retries=$1
    local delay=$2
    local command="${@:3}"

    for ((i=1; i<=retries; i++)); do
        if ! $command && return 0
        log "Attempt $i failed. Retrying in $delay seconds..."
        sleep $delay
        if $i = $retries; then
            exit_on_error "Command failed after $retries attempts: $command"
    done
}

# Initialize Vault if not already initialized
log "Checking Vault status..."
if ! vault status > /dev/null 2>&1; then
    log "Vault is not initialized. Initializing Vault..."
    ./scripts/init-vault.sh || exit_on_error "Failed to initialize Vault."
fi

# Get CA admin credentials from Vault
log "Retrieving CA admin credentials from Vault..."
export FABRIC_CA_ADMIN_USER=$(vault kv get -field=username pesachain/org.pesachain.com/user/admin_creds) || exit_on_error "Failed to get CA admin username from Vault."
export FABRIC_CA_ADMIN_PASSWORD=$(vault kv get -field=password pesachain/org.pesachain.com/user/admin_creds) || exit_on_error "Failed to get CA admin password from Vault."

# Retrieve certificates from Vault and store them in temporary files
log "Retrieving certificates from Vault..."

# PesachainOrg CA certificates
retry_command 3 5 "vault kv get -field=cert pesachain/org.pesachain.com/ca > /tmp/pesachain-org-ca-cert.pem"
retry_command 3 5 "vault kv get -field=key pesachain/org.pesachain.com/ca > /tmp/pesachain-org-ca-key.pem"
retry_command 3 5 "vault kv get -field=chain pesachain/org.pesachain.com/ca > /tmp/pesachain-org-ca-chain.pem"

# PesachainOrg TLS certificates
retry_command 3 5 "vault kv get -field=cert pesachain/org.pesachain.com/tlsca > /tmp/pesachain-org-tls-cert.pem"
retry_command 3 5 "vault kv get -field=key pesachain/org.pesachain.com/tlsca > /tmp/pesachain-org-tls-key.pem"

# OrdererOrg CA certificates
retry_command 3 5 "vault kv get -field=cert pesachain/orderer.pesachain.com/ca > /tmp/orderer-org-ca-cert.pem"
retry_command 3 5 "vault kv get -field=key pesachain/orderer.pesachain.com/ca > /tmp/orderer-org-ca-key.pem"

# OrdererOrg TLS certificates
retry_command 3 5 "vault kv get -field=cert pesachain/orderer.pesachain.com/tlsca > /tmp/orderer-org-tls-cert.pem"
retry_command 3 5 "vault kv get -field=key pesachain/orderer.pesachain.com/tlsca > /tmp/orderer-org-tls-key.pem"

# Ensure the certificates are retrieved
for cert in /tmp/pesachain-org-ca-cert.pem /tmp/pesachain-org-ca-key.pem /tmp/pesachain-org-ca-chain.pem \
           /tmp/pesachain-org-tls-cert.pem /tmp/pesachain-org-tls-key.pem \
           /tmp/orderer-org-ca-cert.pem /tmp/orderer-org-ca-key.pem \
           /tmp/orderer-org-tls-cert.pem /tmp/orderer-org-tls-key.pem; do
    if [ ! -f "$cert" ]; then
        exit_on_error "Certificate $cert not retrieved properly."
    fi
done

# Start CA services with credentials from Vault
log "Starting CA services..."
sleep 3
retry_command 5 10 "docker-compose -f ../docker/docker-compose-ca.yaml up -d" || exit_on_error "Failed to start CA services."

# Wait for CAs to be ready
log "Waiting for CAs to be ready..."
sleep 10  # Add more logic here if necessary (e.g., waiting for logs to confirm readiness)

# Start the rest of the network
log "Starting orderers and peers..."
retry_command 5 10 "docker-compose -f docker/docker-compose-orderer.yaml up -d" || exit_on_error "Failed to start orderers."
retry_command 5 10 "docker-compose -f docker/docker-compose-peers.yaml up -d" || exit_on_error "Failed to start peers."

# Create channels
log "Creating channels..."
./scripts/create-channels.sh || exit_on_error "Failed to create channels."

log "Network started successfully with Vault integration"

# Clean up temporary certificates files
log "Cleaning up temporary files..."
rm -f /tmp/pesachain-org-ca-cert.pem /tmp/pesachain-org-ca-key.pem /tmp/pesachain-org-ca-chain.pem \
      /tmp/pesachain-org-tls-cert.pem /tmp/pesachain-org-tls-key.pem \
      /tmp/orderer-org-ca-cert.pem /tmp/orderer-org-ca-key.pem \
      /tmp/orderer-org-tls-cert.pem /tmp/orderer-org-tls-key.pem
log "Temporary files cleaned up."
