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
    config = { path = "/Vault/vault-tokens/admin/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/ca.ctmpl"
  destination = "/Vault/vault-secrets/admin/ca/ca-cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/tls.ctmpl"
  destination = "/Vault/vault-secrets/admin/tlsca/tlsca-cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/prvKey.ctmpl"
  destination = "/Vault/vault-secrets/admin/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/signcerts.ctmpl"
  destination = "/Vault/vault-secrets/admin/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}
