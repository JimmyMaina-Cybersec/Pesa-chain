auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/org2-client1-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/org2-client1-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/client/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/org2/org2-ca.ctmpl"
  destination = "/Vault/vault-secrets/client/ca/ca.org2.example.com-cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/org2-tls.ctmpl"
  destination = "/Vault/vault-secrets/client/tlsca/tlsca.org2.example.com-cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/client1-prvKey.ctmpl"
  destination = "/Vault/vault-secrets/client/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/client1-signcert.ctmpl"
  destination = "/Vault/vault-secrets/client/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}
