// Admin policy
path "pesachain/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

// Read-only policy for certificates
path "pesachain/certificates/*" {
  capabilities = ["read", "list"]
}

// CA policy for certificate management
path "pesachain/ca/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}