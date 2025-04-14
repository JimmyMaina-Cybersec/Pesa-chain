#!/bin/bash

mkdir -p /Vault/vault-secrets/admin/ca/ \
         /Vault/vault-secrets/admin/tlsca/ \
         /Vault/vault-secrets/admin/msp/keystore \
         /Vault/vault-secrets/admin/msp/signcerts \

exec vault "$@"