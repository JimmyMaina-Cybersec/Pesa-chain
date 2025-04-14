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
    config = { path = "/Vault/vault-tokens/certRenewalService/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/ca.ctmpl"
  destination = "/Vault/vault-secrets/certRenewalService/ca/ca-cert.pem"
  token_file  = "/Vault/vault-tokens/certRenewalService/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/tls.ctmpl"
  destination = "/Vault/vault-secrets/certRenewalService/tlsca/tlsca-cert.pem"
  token_file  = "/Vault/vault-tokens/certRenewalService/token.txt"
}
