#!/bin/bash

mkdir -p /Vault/vault-secrets/client/ca/ \
         /Vault/vault-secrets/client/tlsca/ \
         /Vault/vault-secrets/client/msp/keystore \
         /Vault/vault-secrets/client/msp/signcerts \
         /Vault/vault-secrets/client/tls

exec vault "$@"