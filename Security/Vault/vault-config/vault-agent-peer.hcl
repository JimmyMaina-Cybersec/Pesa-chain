auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/peer/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/ca.ctmpl"
  destination = "/Vault/vault-secrets/peer/ca/ca-cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/tls.ctmpl"
  destination = "/Vault/vault-secrets/peer/tlsca/tlsca-cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/prvKey.ctmpl"
  destination = "/Vault/vault-secrets/peer/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/signcert.ctmpl"
  destination = "/Vault/vault-secrets/peer/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/srvCert.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/server.crt"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/srvKey.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/server.key"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/caCert.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/ca.crt"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}
