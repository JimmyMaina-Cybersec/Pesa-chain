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
    config = { path = "/Vault/vault-tokens/client/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/org2/ca.ctmpl"
  destination = "/Vault/vault-secrets/client/ca/ca-cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/ca.ctmpl"
  destination = "/Vault/vault-secrets/client/ca/ca-cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/ca.ctmpl"
  destination = "/Vault/vault-secrets/client/ca/ca-cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/prvKey.ctmpl"
  destination = "/Vault/vault-secrets/client/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/signcert.ctmpl"
  destination = "/Vault/vault-secrets/client/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/tlsca1.ctmpl"
  destination = "/Vault/vault-secrets/client/tls/ca1.crt"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/tlsca2.ctmpl"
  destination = "/Vault/vault-secrets/client/tls/ca2.crt"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/tlsca3.ctmpl"
  destination = "/Vault/vault-secrets/client/tls/ca3.crt"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/tlsca.ctmpl"
  destination = "/Vault/vault-secrets/client/tlsca/pesachainTlsca.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/tlsca.ctmpl"
  destination = "/Vault/vault-secrets/client/tlsca/org2Tlsca.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}
