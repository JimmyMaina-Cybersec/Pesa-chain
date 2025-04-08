auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/Vault/vault-creds/org2-certrenewalservice-role_roleid.txt"
      secret_id_file_path = "/Vault/vault-creds/org2-certrenewalservice-role_secretid.txt"
      remove_secret_id_file_after_reading = false
    }
  }
  sink {
    type = "file"
    config = { path = "/Vault/vault-tokens/certRenewalService/token.txt" }
  }
}

template {
  source      = "/Vault/vault-tmpl/org2/org2-ca.ctmpl"
  destination = "/Vault/vault-secrets/certRenewalService/ca/ca.org2.example.com-cert.pem"
  token_file  = "/Vault/vault-tokens/certRenewalService/token.txt"
}

template {
  source      = "/Vault/vault-tmpl/org2/org2-tls.ctmpl"
  destination = "/Vault/vault-secrets/certRenewalService/tlsca/tlsca.org2.example.com-cert.pem"
  token_file  = "/Vault/vault-tokens/certRenewalService/token.txt"
}
