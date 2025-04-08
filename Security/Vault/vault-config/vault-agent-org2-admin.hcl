auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/org2-admin-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/org2-admin-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/admin/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/org2/org2-ca.ctmpl"
  destination = "/Vault/vault-secrets/admin/ca/ca.org2.example.com-cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/org2-tls.ctmpl"
  destination = "/Vault/vault-secrets/admin/tlsca/tlsca.org2.example.com-cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/admin-prvKey.ctmpl"
  destination = "/Vault/vault-secrets/admin/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/admin-signcerts.ctmpl"
  destination = "/Vault/vault-secrets/admin/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}
