#!/bin/bash

mkdir -p /Vault/vault-secrets/certRenewalService/ca/ \
         /Vault/vault-secrets/certRenewalService/tlsca/ \

exec vault "$@"