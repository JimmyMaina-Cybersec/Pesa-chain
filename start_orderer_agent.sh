#!/bin/bash

# Create required folders
mkdir -p /Vault/vault-secrets/orderer/msp/signcerts \
         /Vault/vault-secrets/orderer/msp/keystore \
         /Vault/vault-secrets/orderer/tls \
         /Vault/vault-secrets/orderer/ca \

# Start vault agent with passed args
exec vault "$@"
