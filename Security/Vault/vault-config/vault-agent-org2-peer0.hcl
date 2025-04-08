auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/org2-peer0-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/org2-peer0-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/peer/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/org2/org2-ca.ctmpl"
  destination = "/Vault/vault-secrets/peer/ca/ca.org2.example.com-cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/org2-tls.ctmpl"
  destination = "/Vault/vault-secrets/peer/tlsca/tlsca.org2.example.com-cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/peer0-prvKey.ctmpl"
  destination = "/Vault/vault-secrets/peer/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/peer0-signcert.ctmpl"
  destination = "/Vault/vault-secrets/peer/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/peer0-srvCert.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/server.crt"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/peer0-srvKey.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/server.key"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/peer0-caCert.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/ca.crt"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}
