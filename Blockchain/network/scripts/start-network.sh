#!/bin/bash

set -e

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Initialize Vault if not already initialized
if ! vault status > /dev/null 2>&1; then
    log "Initializing Vault..."
    ./scripts/init-vault.sh
fi

# Get CA admin credentials from Vault
export FABRIC_CA_ADMIN_USER=$(vault kv get -field=username pesachain/ca/admin)
export FABRIC_CA_ADMIN_PASSWORD=$(vault kv get -field=password pesachain/ca/admin)

# Start CAs with credentials from Vault
log "Starting CA services..."
docker-compose -f docker/docker-compose-ca.yaml up -d

# Wait for CAs to be ready
sleep 10

# Start the rest of the network
log "Starting orderers and peers..."
docker-compose -f docker/docker-compose-orderer.yaml up -d
docker-compose -f docker/docker-compose-peers.yaml up -d

# Create channels
log "Creating channels..."
./scripts/create-channels.sh

log "Network started successfully with Vault integration"