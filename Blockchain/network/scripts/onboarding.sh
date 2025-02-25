#!/bin/bash
set -euo pipefail

source ./init-vault.sh  # Assumes this sets NAMESPACE, VAULT_POD, and logging functions

# ---- Input Validation Functions ----

validate_input() {
    local prompt="$1"
    local input=""
    while [[ -z "$input" ]]; do
        read -rp "$prompt" input
    done
    echo "$input"
}

validate_domain() {
    local domain=""
    local prompt="Enter a valid domain (e.g., example.com): "
    while [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; do
        read -rp "$prompt" domain
    done
    echo "$domain"
}

# ---- Step C: Update Channel Configuration Function ----

update_channel_config() {
    log "Starting channel configuration update to onboard new organization..."
    CHANNEL=$(validate_input "Enter the channel name to update (e.g., mychannel): ")
    ORDERER_ADDRESS=$(validate_input "Enter the orderer address (e.g., orderer.example.com:7050): ")

    log "Fetching current channel configuration for channel $CHANNEL..."
    peer channel fetch config config_block.pb -o "$ORDERER_ADDRESS" -c "$CHANNEL"

    log "Decoding channel configuration to JSON..."
    sleep 1
    configtxlator proto_decode --input config_block.pb --type common.Config > config.json

    # Ensure new_org.json exists (it should contain the new org's MSP config)
    if [ ! -f new_org.json ]; then
        logError "new_org.json not found. Create this file with the new organization's configuration snippet."
        exit 1
    fi

    log "Merging new organization configuration from new_org.json into channel config..."
    sleep 1
    # This jq command merges the new organization's configuration into the Application groups.
    jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": .[1]}}}}' config.json new_org.json > modified_config.json

    log "Encoding original and modified configurations to protobuf..."
    sleep 1
    configtxlator proto_encode --input config.json --type common.Config --output config.pb
    configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

    log "Computing configuration update..."
    sleep 1
    configtxlator compute_update --channel_id "$CHANNEL" --original config.pb --updated modified_config.pb --output update.pb

    log "Decoding configuration update to JSON..."
    sleep 1
    configtxlator proto_decode --input update.pb --type common.ConfigUpdate > update.json

    log "Wrapping configuration update in an envelope..."
    sleep 1
    cat <<EOF > update_in_envelope.json
{
  "payload": {
    "header": {
      "channel_header": {
        "channel_id": "$CHANNEL",
        "type": 2
      }
    },
    "data": {
      "config_update": $(cat update.json)
    }
  }
}
EOF

    log "Encoding envelope to protobuf..."
    sleep 1
    configtxlator proto_encode --input update_in_envelope.json --type common.Envelope --output update_in_envelope.pb

    log "Submitting channel configuration update..."
    sleep 1
    peer channel update -f update_in_envelope.pb -c "$CHANNEL" -o "$ORDERER_ADDRESS"
    logSuccess "Channel configuration updated successfully to include the new organization."
}

# ---- Main Onboarding Function ----

main() {
    log "Prompting for new organization details..."
    sleep 2
    ORG_NAME=$(validate_input "Enter the organization name: ")
    ORG_DOMAIN=$(validate_domain)
    MAX_TTL=$(validate_input "Enter max TTL for the org CA (e.g., 8760h): ")
    ENTITY_TTL="2190h"  # Default 3 months

    log "Onboarding organization: $ORG_NAME with domain: $ORG_DOMAIN ..."
    sleep 1

    # ---- Step A: Configure PKI Engine for the Organization ----
    log "Enabling PKI secrets engine for $ORG_NAME..."
    sleep 2
    if ! error_message=(kubectl exec -i VAULT-0 -n "$NAMESPACE" -- vault secrets enable -path=pki/$ORG_NAME pki); then
        logError "Failed to enable PKI engine for $ORG_NAME- $error_message"
        clean_up_vault
        exit 1
    fi

    log "Configuring max TTL ($MAX_TTL) for $ORG_NAME's PKI..."
    kubectl exec -i VAULT-0 -n "$NAMESPACE" -- vault secrets tune -max-lease-ttl="$MAX_TTL" pki/$ORG_NAME

    log "Generating intermediate CA CSR for $ORG_NAME..."
    sleep 2
    if ! error_message=(kubectl exec -i VAULT-0 -n "$NAMESPACE" -- vault write pki/$ORG_NAME/intermediate/generate/internal \
        common_name="$ORG_DOMAIN Intermediate CA" \
        ttl="$MAX_TTL" -format=json | jq -r .data.csr > /tmp/"$ORG_NAME".csr); then
            logError "Failed to generate intermediate CA CSR for $ORG_NAME- $error_message"
            clean_up_vault
            exit 1
        fi
    logSuccess "Intermediate CSR for $ORG_NAME generated."
    sleep 1

    log "Copying CSR to Vault pod..."
    if ! error_message=(kubectl cp /tmp/"$ORG_NAME".csr "$VAULT_POD":/tmp/"$ORG_NAME".csr -n "$NAMESPACE"); then
        logError "Failed to copy CSR to Vault pod- $error_message"
        clean_up_vault
        exit 1
    fi

    log "Signing the intermediate CSR with pesachainCA..."
    if ! error_message=(kubectl exec VAULT-0 -n "$NAMESPACE" -- vault write pesachain_pki/root/sign-intermediate \
        csr=@/tmp/"$ORG_NAME".csr \
        format=pem_bundle ttl="$MAX_TTL" -format=json | jq -r .data.certificate > /tmp/"$ORG_NAME".crt); then
            logError "Failed to sign intermediate CSR for $ORG_NAME- $error_message"
            clean_up_vault
            exit 1
        fi

    log "Importing signed intermediate certificate into $ORG_NAME's PKI engine..."
    if ! error_message=(kubectl exec -i VAULT-0 -n "$NAMESPACE" -- vault write pki/$ORG_NAME/intermediate/set-signed \
        certificate=- < /tmp/"$ORG_NAME".crt); then
            logError "Failed to import signed intermediate certificate for $ORG_NAME- $error_message"
            clean_up_vault
            exit 1
        fi
    logSuccess "Intermediate CA for $ORG_NAME signed and imported."
    sleep 1

    log "Setting issuing and CRL distribution URLs for $ORG_NAME..."
    if ! error_message=(kubectl exec VAULT-0 -n "$NAMESPACE" -- vault write pki/$ORG_NAME/config/urls \
        issuing_certificates="http://127.0.0.1:8200/v1/pki/$ORG_NAME/ca" \
        crl_distribution_points="http://127.0.0.1:8200/v1/pki/$ORG_NAME/crl"); then
            logError "Failed to set issuing/CRL URLs for $ORG_NAME- $error_message"
            clean_up_vault
            exit 1
        fi
    logSuccess "Issuing and CRL URLs configured for $ORG_NAME."
    sleep 1

    log "Creating certificate issuance role for $ORG_NAME..."
    if ! error_message=(kubectl exec VAULT-0 -n "$NAMESPACE" -- vault write pki/$ORG_NAME/roles/"$ORG_NAME-role" \
        allowed_domains="${ORG_DOMAIN}" \
        allow_subdomains=true \
        max_ttl="$ENTITY_TTL"); then
            logError "Failed to create certificate role for $ORG_NAME- $error_message"
            clean_up_vault
            exit 1
        fi
    logSuccess "Certificate role for $ORG_NAME created successfully."
    sleep 1

    # ---- Step B: Generate MSP (Membership Service Provider) Structure ----
    log "Storing the organization's CA certificate in Vault KV store..."
    sleep 1
    if ! error_message=$(kubectl exec -i VAULT-0 -n "$NAMESPACE" -- vault kv put secret/org_certs/"$ORG_NAME" cert="$(cat /tmp/"$ORG_NAME".crt)"); then
        logError "Failed to store organization CA certificate in Vault KV- $error_message"
        clean_up_vault
        exit 1
    fi
    logSuccess "Organization CA certificate stored in Vault KV."

    log "Retrieving CA certificate from Vault KV..."
    if ! error_message=$(kubectl exec -i VAULT-0 -n "$NAMESPACE" -- vault kv get -field=cert secret/org_certs/"$ORG_NAME" > /tmp/"$ORG_NAME"-ca-cert.pem); then
        logError "Failed to retrieve organization CA certificate from Vault KV"
        clean_up_vault
        exit 1
    fi

    MSP_DIR="crypto-config/${ORG_NAME}/msp"
    log "Creating MSP directory structure at '$MSP_DIR'..."
    mkdir -p "$MSP_DIR"/{admincerts,cacerts,tlscacerts,keystore,signcerts}

    cp /tmp/"$ORG_NAME"-ca-cert.pem "$MSP_DIR/cacerts/ca.pem"
    logSuccess "CA certificate copied to MSP cacerts."

    log "Issuing admin certificate for $ORG_NAME..."
    if ! error_message=$(kubectl exec -i VAULT-0 -n "$NAMESPACE" -- vault write pesachain_pki/issue/new_organizations \
        common_name="admin@${ORG_NAME}.${ORG_DOMAIN}" \
        ttl="8760h" -format=json | jq -r .data.certificate > /tmp/"$ORG_NAME"-admin-cert.pem); then
            logError "Failed to issue admin certificate for $ORG_NAME"
            clean_up_vault
            exit 1
        fi
    cp /tmp/"$ORG_NAME"-admin-cert.pem "$MSP_DIR/admincerts/admin.pem"
    logSuccess "Admin certificate copied to MSP admincerts."

    logSuccess "MSP structure generated for organization $ORG_NAME at '$MSP_DIR'."

    # ---- Step C: Update Fabric Channel Configuration ----
    update_channel_config
    logSuccess "Organization $ORG_NAME has been successfully onboarded into the Fabric network."
}

main "$@"
