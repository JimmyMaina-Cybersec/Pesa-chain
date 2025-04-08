auto_auth {
  method {
    type = "approle"

    config = {
      role_id_file_path = "/Vault/vault-creds/orderer2-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/orderer2-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/orderer/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/orderer2/orderer2-signcerts.ctmpl"
  destination = "/Vault/vault-secrets/orderer/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/orderer2/orderer2-prvKey.ctmpl"
  destination = "/Vault/vault-secrets/orderer/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/orderer2/orderer2-srvCert.ctmpl"
  destination = "/Vault/vault-secrets/orderer/tls/server.crt"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/orderer2/orderer2-srvKey.ctmpl"
  destination = "/Vault/vault-secrets/orderer/tls/server.key"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/orderer2/orderer2-ca.ctmpl"
  destination = "/Vault/vault-secrets/orderer/ca/ca-orderer-com-9054-ca-orderer-com.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}
