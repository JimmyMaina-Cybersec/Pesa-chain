auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/pesachain-peer1-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/pesachain-peer1-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/peer/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/pesachain/pesachain-ca.ctmpl"
  destination = "/Vault/vault-secrets/peer/ca/ca.pesachain.com-cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/pesachain-tls.ctmpl"
  destination = "/Vault/vault-secrets/peer/tlsca/tlsca.pesachain.com-cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/peer1-prvKey.ctmpl"
  destination = "/Vault/vault-secrets/peer/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/peer1-signcert.ctmpl"
  destination = "/Vault/vault-secrets/peer/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/peer1-srvCert.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/server.crt"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/peer1-srvKey.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/server.key"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/peer1-caCert.ctmpl"
  destination = "/Vault/vault-secrets/peer/tls/ca.crt"
  token_file  = "/Vault/vault-tokens/peer/token.txt"
}