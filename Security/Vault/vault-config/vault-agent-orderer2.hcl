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
    config = { path = "/Vault/vault-tokens/orderer/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/signcerts.ctmpl"
  destination = "/Vault/vault-secrets/orderer/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/prvKey.ctmpl"
  destination = "/Vault/vault-secrets/orderer/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/srvCert.ctmpl"
  destination = "/Vault/vault-secrets/orderer/tls/server.crt"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/srvKey.ctmpl"
  destination = "/Vault/vault-secrets/orderer/tls/server.key"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/ca.ctmpl"
  destination = "/Vault/vault-secrets/orderer/ca/ca-orderer-com-9054-ca-orderer-com.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}
