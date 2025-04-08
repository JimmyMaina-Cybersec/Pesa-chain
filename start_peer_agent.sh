#!/bin/bash

mkdir -p /Vault/vault-secrets/peer/ca/ \
         /Vault/vault-secrets/peer/tlsca/ \
         /Vault/vault-secrets/peer/msp/keystore \
         /Vault/vault-secrets/peer/msp/signcerts \
         /Vault/vault-secrets/peer/tls/ \

exec vault "$@"