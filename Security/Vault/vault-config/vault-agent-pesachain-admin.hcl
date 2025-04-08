auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/pesachain-admin-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/pesachain-admin-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/admin/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/pesachain/pesachain-ca.ctmpl"
  destination = "/Vault/vault-secrets/admin/ca/ca.pesachain.com-cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/pesachain-tls.ctmpl"
  destination = "/Vault/vault-secrets/admin/tlsca/tlsca.pesachain.com-cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/admin-prvKey.ctmpl"
  destination = "/Vault/vault-secrets/admin/msp/keystore/prvKey.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/admin-signcert.ctmpl"
  destination = "/Vault/vault-secrets/admin/msp/signcerts/cert.pem"
  token_file  = "/Vault/vault-tokens/admin/token.txt"
}
