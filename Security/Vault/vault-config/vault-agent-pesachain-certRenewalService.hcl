auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/pesachain-certrenewalservice-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/pesachain-certrenewalservice-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/certRenewalService/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/pesachain/pesachain-ca.ctmpl"
  destination = "/Vault/vault-secrets/certRenewalService/ca/ca.pesachain.com-cert.pem"
  token_file  = "/Vault/vault-tokens/certRenewalService/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/pesachain/pesachain-tls.ctmpl"
  destination = "/Vault/vault-secrets/certRenewalService/tlsca/tlsca.pesachain.com-cert.pem"
  token_file  = "/Vault/vault-tokens/certRenewalService/token.txt"
}

