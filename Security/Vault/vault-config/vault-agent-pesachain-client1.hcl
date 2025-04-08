auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/pesachain-client1-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/pesachain-client1-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/client/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/pesachain/pesachain-ca.ctmpl"
  destination = "/Vault/vault-secrets/client/ca/ca.pesachain.com-cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/pesachain-tls.ctmpl"
  destination = "/Vault/vault-secrets/client/tlsca/tlsca.pesachain.com-cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/client1-prvKey.ctmpl"
  destination = "/Vault/vault-secrets/client/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/client1-signcert.ctmpl"
  destination = "/Vault/vault-secrets/client/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/client/token.txt"
}
