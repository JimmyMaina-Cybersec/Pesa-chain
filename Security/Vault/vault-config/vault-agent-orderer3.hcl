auto_auth {
  method {
    type = "approle"

    config = {
      role_id_file_path = "/Vault/vault-creds/orderer3-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/orderer3-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/orderer/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/orderer3/orderer3-signcerts.ctmpl"
  destination = "/Vault/vault-secrets/orderer/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/orderer3/orderer3-prvKey.ctmpl"
  destination = "/Vault/vault-secrets/orderer/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/orderer3/orderer3-srvCert.ctmpl"
  destination = "/Vault/vault-secrets/orderer/tls/server.crt"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/orderer3/orderer3-srvKey.ctmpl"
  destination = "/Vault/vault-secrets/orderer/tls/server.key"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/orderer3/orderer3-ca.ctmpl"
  destination = "/Vault/vault-secrets/orderer/ca/ca-orderer-com-9054-ca-orderer-com.pem"
  token_file  = "/Vault/vault-tokens/orderer/token.txt"
}
