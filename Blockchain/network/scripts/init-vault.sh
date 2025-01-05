#!/bin/bash

# Logging function with timestamp and typewriter effect for the message
log() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local message="$1"
    local delay=${2:-0.02}
    local orange_color='\033[38;5;214m'
    local reset_color='\033[0m'

    sleep 0.8

    # Print timestamp normally
    echo -n "$timestamp - "

    tput civis  # Hide cursor
    echo -ne "$orange_color"
    while IFS= read -r -n1 char; do
        if [[ "$char" == $'\n' ]]; then
            printf "\n"
        else
            printf "%b" "$char"
        fi
        sleep "$delay"
    done <<< "$(echo -e "$message")"
    echo -ne "$reset_color"
    tput cnorm  # Ensure cursor is visible
    echo
}

# Logging error function with timestamp and typewriter effect for the message
logError() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local message="$1"
    local delay=${2:-0.02}
    local red_color='\033[38;5;196m'
    local reset_color='\033[0m'

    sleep 0.8
    echo
    echo -ne "$red_color$timestamp - $reset_color"

    # Print message with typewriter effect in default color
    tput civis  # Hide cursor
    while IFS= read -r -n1 char; do
        if [[ "$char" == $'\n' ]]; then
            printf "\n"
        else
            printf "%b" "$char"
        fi
        sleep "$delay"
    done <<< "$(echo -e "$message")"
    tput cnorm  # Ensure cursor is visible
    echo
    echo
}

logWarning() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local message="$1"
    local delay=${2:-0.02}
    local yellow_color='\033[38;5;229m'
    local reset_color='\033[0m'

    sleep 0.8
    echo -ne "$yellow_color$timestamp - $reset_color"

    # Print message with typewriter effect in default color
    tput civis  # Hide cursor
    while IFS= read -r -n1 char; do
        if [[ "$char" == $'\n' ]]; then
            printf "\n"
        else
            printf "%b" "$char"
        fi
        sleep "$delay"
    done <<< "$(echo -e "$message")"
    tput cnorm  # Ensure cursor is visible
    echo
}

logSuccess() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local message="$1"
    local delay=${2:-0.02}
    local green_color='\033[38;5;22m'
    local reset_color='\033[0m'

    sleep 0.8
    echo
    echo -ne "$green_color$timestamp - $reset_color"

    # Print message with typewriter effect in default color
    tput civis  # Hide cursor
    while IFS= read -r -n1 char; do
        if [[ "$char" == $'\n' ]]; then
            printf "\n"
        else
            printf "%b" "$char"
        fi
        sleep "$delay"
    done <<< "$(echo -e "$message")"
    tput cnorm  # Ensure cursor is visible
    echo
    echo
}

# Function to handle errors and trigger cleanup
exit_on_error() {
  logError "ERROR: $1"
  backup_and_cleanup
  exit 1
}

# Function to insert data into MongoDB
mongo_insert() {
  local key=$1
  local value=$2
  local json_doc="{\"key\":\"$key\", \"value\":\"$value\"}"

  # Attempt to insert
  result=$(echo "db.BackupCertsAndCreds.insertOne($json_doc)" | mongosh "${MONGO_URI}" 2>&1)
  if [[ $? -eq 0 ]]; then
    logSuccess "Successfully backed up $key to MongoDB."
  else
    logWarning "Failed to back up $key to MongoDB. Error: $result"
  fi
}

# Function to check if a certificate exists in Vault before backing up
check_and_store_certificate() {
  local vault_path=$1
  if kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv get -format=json "$vault_path" > /dev/null 2>&1; then
    logSuccess "Found $vault_path in Vault. Retrieving and storing in MongoDB..."
    sleep 3
    cert_data=$(kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv get -format=json "$vault_path" | jq -r '.data.data')
    mongo_insert "$vault_path" "$cert_data"
  else
    error_message=$(kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv get -format=json "$vault_path" 2>&1)
    logWarning "$vault_path not found in Vault. Skipping its backup. Error: $error_message"
  fi
}

# Function to back up certificates from Vault to MongoDB
backup_certificates() {
  vault_paths=$(kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv list -format=json "pesachain" 2>/dev/null | jq -r '.[]')
  total_certificates=0
  skipped_certificates=0
  if [[ -z "$vault_paths" ]]; then
    logWarning "'pesachain' path not found or no secrets/paths present. Skipping backup..."
    sleep 1
    clean_up_vault
    return
  fi
  for sub_path in $vault_paths; do
    local full_vault_path="pesachain/$sub_path"
    if [[ "$sub_path" =~ \.(pem|priv_sk|crt|key)$ ]]; then
      total_certificates=$((total_certificates + 1))
      check_and_store_certificate "$full_vault_path" || skipped_certificates=$((skipped_certificates + 1))
    fi
  done
  log "$total_certificates certificates processed. $skipped_certificates skipped."
}

# Function to retrieve and store Auth0 secrets in MongoDB
backup_auth0_secrets() {
  auth0_paths=$(kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv list -format=json "pesachain/auth0" | jq -r '.[]')

  if [[ -z "$auth0_paths" ]]; then
    logWarning "No Auth0 secrets found under 'pesachain/auth0'. Skipping backup."
    return
  fi

  for auth0_secret in $auth0_paths; do
    full_auth0_path="pesachain/auth0/$auth0_secret"
    if kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv get -format=json "$full_auth0_path" > /dev/null 2>&1; then
      secret_data=$(kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv get -format=json "$full_auth0_path" | jq -r '.data.data')
      mongo_insert "$full_auth0_path" "$secret_data"
    else
      logWarning "Failed to retrieve Auth0 secret: $auth0_secret. Skipping..."
      sleep 1
    fi
  done

  logSuccess "Auth0 secrets backup to MongoDB completed."
}

# Function to clean up the Vault namespace and associated resources
clean_up_vault() {
  log "Starting cleanup process..."
  sleep 2

  # Check if NAMESPACE is non-empty and delete it
  if [[ -n "$NAMESPACE" ]]; then
    kubectl delete namespace "$NAMESPACE" --wait --timeout=300s || logError "Failed to delete namespace $NAMESPACE."

    # Retry logic for deleting the namespace
    for attempt in {1..5}; do
      if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        logWarning "Retry $attempt: Namespace $NAMESPACE still exists. Waiting..."
        sleep 3
      else
        logSuccess "Namespace $NAMESPACE successfully deleted."
        break
      fi

      if [[ $attempt -eq 5 ]]; then
        logError "Failed to delete namespace $NAMESPACE after 5 attempts."
        sleep 1
        exit 1
      fi
    done
  else
    log "NAMESPACE is not set. Skipping namespace deletion..."
    sleep 1
  fi

  # Delete Persistent Volume Claims (PVCs) if any
  if kubectl get pvc -n "$NAMESPACE" &> /dev/null; then
    sleep 1
    log "Deleting Persistent Volume Claims (PVCs)..."
    sleep 3
    kubectl delete pvc --all -n "$NAMESPACE" --wait || logError "Failed to delete PVCs in namespace $NAMESPACE."
    kubectl wait --for=delete pvc --all -n "$NAMESPACE" --timeout=60s || logError "PVCs were not deleted in namespace $NAMESPACE within the timeout."
  else
  echo
    log "No Persistent Volume Claims (PVCs) found."
  fi

  # Delete ClusterRoles and ClusterRoleBindings associated with Vault
  if kubectl get clusterrole vault-agent-injector-clusterrole &> /dev/null; then
    sleep 1
    log "Deleting ClusterRole vault-agent-injector-clusterrole..."
    echo
    sleep 3
    kubectl delete clusterrole vault-agent-injector-clusterrole || logError "Failed to delete ClusterRole vault-agent-injector-clusterrole."
    kubectl wait --for=delete clusterrole vault-agent-injector-clusterrole --timeout=60s || logError "ClusterRole vault-agent-injector-clusterrole was not deleted within the timeout."
  else
    echo
    log "ClusterRole vault-agent-injector-clusterrole not found."
  fi

  if kubectl get clusterrolebinding vault-agent-injector-binding &> /dev/null; then
    sleep 1
    log "Deleting ClusterRoleBinding vault-agent-injector-binding..."
    echo
    sleep 3
    kubectl delete clusterrolebinding vault-agent-injector-binding || logError "Failed to delete ClusterRoleBinding vault-agent-injector-binding."
    kubectl wait --for=delete clusterrolebinding vault-agent-injector-binding --timeout=60s || logError "ClusterRoleBinding vault-agent-injector-binding was not deleted within the timeout."
  else
    log "ClusterRoleBinding vault-agent-injector-binding not found."
  fi

  # Purge Helm release
  if helm list -n "$NAMESPACE" | grep -q "^vault"; then
    sleep 1
    log "Uninstalling Helm release 'vault'..."
    sleep 3
    helm uninstall vault --namespace "$NAMESPACE" || logError "Failed to uninstall Helm release 'vault'."
    logSuccess "Helm release 'vault' uninstalled successfully."
  else
    log "Helm release 'vault' not found in namespace $NAMESPACE."
  fi

  if kubectl get secrets -n kube-system | grep -q "^sh.helm.release.v1.vault"; then
  sleep 1
  log "Deleting Helm release secrets..."
  sleep 3
  secrets=$(kubectl get secrets -n kube-system | grep "^sh.helm.release.v1.vault" | awk '{print $1}')
  if [[ -n "$secrets" ]]; then
    kubectl delete secret -n kube-system $secrets || logError "Failed to delete Helm release secrets."
  else
    logWarning "No matching Helm release secrets found after filtering."
  fi
else
  log "Helm release secrets not found."
fi

  logSuccess "Cleanup completed."
  sleep 1
}

trap 'rm -f /tmp/vault-init.json; rm -rf ../vault-cred/*' EXIT

# Main function to back up certificates and Auth0 secrets
backup_and_cleanup() {
  log "Starting backup process..."
  sleep 3

  log "Backing up certificates..."
  sleep 3
  backup_certificates

  log "Backing up Auth0 secrets..."
  sleep 3
  backup_auth0_secrets

  log "Backup completed. Proceeding with cleanup..."
  sleep 1.5
  clean_up_vault
}

# Function to validate required environment variables and MongoDB connection
validate_env_vars() {
  # List of required environment variables
  required_vars=(
    AUTH0_DOMAIN
    AUTH0_CLIENT_ID
    AUTH0_CLIENT_SECRET
    AUTH0_AUDIENCE
    MONGO_URI
    NAMESPACE
  )

  log "Ensuring all required environment variables are set..."
  sleep 3
  for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
      logError "Missing environment variable: $var"
      exit 1
    fi
  done

  log "Checking if MongoDB client (mongosh) is installed..."
  sleep 3
  if ! command -v mongosh &> /dev/null; then
    logError "MongoDB client (mongosh) is not installed or not in PATH. Aborting operation."
    exit 1
  fi

  log "Verifying MongoDB server is accessible..."
  if ! mongosh "${MONGO_URI}" --eval "db.runCommand({ ping: 1 })" &> /dev/null; then
    logError "MongoDB server is not accessible. Please check if it's running and accessible at ${MONGO_URI}."
    exit 1
  fi

  logSuccess "All environment variables are set and MongoDB is accessible."
}

# Function to check Vault pod status
check_vault_pod_status() {
    for i in $(seq 1 "$MAX_RETRIES"); do
      POD_STATUS=$(kubectl get pod VAULT-0 -n "$NAMESPACE" --output=jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")

      if [[ "$POD_STATUS" == "Running" ]]; then
        logSuccess "Vault pod is running."
        return 0
      elif [[ "$POD_STATUS" == "NotFound" ]]; then
        logWarning "Vault pod $VAULT_POD does not exist. Proceeding to deploy one..."
        return 1
      else
        logWarning "Vault pod is not running yet. Current status: $POD_STATUS. Retrying ($i/$MAX_RETRIES)..."
      fi

      sleep "$RETRY_DELAY"
    done

    logWarning "Vault pod is still not running after $MAX_RETRIES attempts. Deleting the faulty pod before proceeding to deploy a new one..."
    sleep 1
    clean_up_vault
    return 1
  }

  # Function to store cryptographic materials
  store_certificate() {
    local path=$1
    local cert_path=$2
    local key_path=$3
    local chain_path=${4:-}

    log "Storing certificates for $path..."
    sleep 1
    echo

    if [[ ! -f "$cert_path" ]] || [[ ! -f "$key_path" ]]; then
      exit_on_error "Certificate or key file not found for $path."
    fi

    local vault_cmd="vault kv put \"$path\" cert=\"\$(cat \"$cert_path\")\" key=\"\$(cat \"$key_path\")\""

    if [[ -n "$chain_path" && -f "$chain_path" ]]; then
      vault_cmd+=" chain=\"\$(cat \"$chain_path\")\""
    fi

    if [[ -z VAULT-0 ]] || [[ -z "$NAMESPACE" ]]; then
      exit_on_error "VAULT_POD or NAMESPACE is not set. Cannot execute kubectl command."
    fi

    log "Executing: $vault_cmd in pod $VAULT_POD in namespace $NAMESPACE ..."
    kubectl exec -it VAULT-0 -n "$NAMESPACE" -- bash -c "$vault_cmd" || exit_on_error "Failed to store certificates for $path."
  }

  # Function to join vault pods to raft
  join_pod_to_raft_cluster() {
    local pod_name=$1

    log "Joining pod $pod_name to raft cluster..."
    sleep 3
    if ! kubectl exec -it $pod_name -- vault operator raft join http://vault-0.vault-internal:8200
      logError "Failed to join $pod_name to raft cluster."
      sleep 1
      clean_up_vault
      exit 1
    else
      logSuccess "$pod_name successfully joined the raft cluster"
  }

  # Fnction to unseal vault pods
  unseal_vault() {
    local pod_name="$1"
    log "Unsealing $pod_name..."
    sleep 3
    for i in {1..3}; do
      # Decrypt the unseal key
      KEY=$(gpg --decrypt ../vault-cred/unseal-keys.gpg | sed -n "${i}p")
      if [[ $? -ne 0 ]]; then
        logError "Failed to decrypt unseal key $i for $pod_name. Cleaning up..."
        sleep 1
        clean_up_vault
        exit 1
      fi

      # Unseal the vault pod
      kubectl exec -it $pod_name -n "$NAMESPACE" -- vault operator unseal "$KEY"
      if [[ $? -ne 0 ]]; then
        logError "Failed to unseal $pod_name with key $i. Cleaning up..."
        sleep 1
        clean_up_vault
        exit 1
      fi
    done
    logSuccess "$pod_name successfully unsealed"
  }

main() {
  # Exit immediately if a command exits with a non-zero status
  # Ensure that the entire pipe fails if any command fails
  set -e
  set -o pipefail

  # Set default values or override from environment variables or command-line args
  NAMESPACE="${NAMESPACE:-vault}"
  MAX_RETRIES=30
  RETRY_DELAY=10

  # Load the configuration file
  log "Loading configuration file..."
  sleep 1
  if [ -f ./.env ]; then
    source ./.env
    # Echo the variables to verify they are loaded
    echo
    echo "AUTH0_DOMAIN=${AUTH0_DOMAIN}"
    sleep 0.8
    echo "AUTH0_CLIENT_ID=${AUTH0_CLIENT_ID}"
    sleep 0.8
    echo "AUTH0_CLIENT_SECRET=${AUTH0_CLIENT_SECRET}"
    sleep 0.8
    echo "AUTH0_AUDIENCE=${AUTH0_AUDIENCE}"
    sleep 0.8
    echo "MONGO_URI=${MONGO_URI}"
    sleep 0.8
    echo "NAMESPACE=${NAMESPACE}"
    sleep 0.8
    echo
  else
    logError "Configuration file .env not found."
    exit 1
  fi

  # Check if required environment variables are set
  validate_env_vars

  # Error Log Redirection
  exec 2>>/tmp/vault-error.log

  # Ensure that the Vault pod is running
  log "Checking if the Vault pod $VAULT_POD is running..."
  sleep 3

  check_vault_pod_status

  # Initial check for Vault pod
  if ! check_vault_pod_status; then
    log "Deploying Vault..."
    sleep 3
    echo

    # Ensure the HashiCorp Helm repository is added
    if helm repo list | grep -q '^hashicorp'; then
      log "HashiCorp Helm repository already exists. Skipping addition."
    else
      log "Adding HashiCorp Helm repository..."
      sleep 3
      if ! helm repo add hashicorp https://helm.releases.hashicorp.com; then
        logWarning "Failed to add Helm repository. Retrying..."
        sleep "$RETRY_DELAY"
        if ! helm repo add hashicorp https://helm.releases.hashicorp.com; then
          logError "Failed to add HashiCorp Helm repository again. Exiting..."
          sleep 1
          exit 1
        fi
      fi
    fi

    # Update Helm repositories
    log "Updating Helm repositories..."
    sleep 3
    echo
    if ! helm repo update; then
      logWarning "Failed to update Helm repositories. Retrying..."
      sleep "$RETRY_DELAY"
      if ! helm repo update; then
        logError "Failed to update Helm repositories again. Exiting..."
        sleep 1
        exit 1
      fi
    fi

    # Deploy or upgrade Vault
    if helm list -n "$NAMESPACE" | grep -q '^vault'; then
      log "Vault release exists. Attempting to upgrade..."
      sleep 3
      echo
      if ! helm upgrade vault hashicorp/vault --namespace "$NAMESPACE" --set "server.dev.enabled=true"; then
        logWarning "Failed to upgrade Vault release. Deleting and redeploying..."
        sleep 3
        if ! helm uninstall vault --namespace "$NAMESPACE"; then
          logError "Failed to delete Vault release. Kindly investigate. Exiting..."
          sleep 1
          exit 1
        fi
        if ! helm install vault hashicorp/vault --namespace "$NAMESPACE" --create-namespace --values helm-vault-raft-values.yaml; then
          logError "Failed to deploy Vault using Helm. Exiting..."
          sleep 1
          exit 1
        fi
      fi
    else
      echo
      log "Deploying Vault using Helm..."
      sleep 3
      echo
      if ! error_message=$(helm install vault hashicorp/vault --namespace "$NAMESPACE" --create-namespace --values helm-vault-raft-values.yaml 2>&1); then
        logError "Failed to deploy Vault using Helm. Error: $error_message"
        sleep 1
        exit 1
      fi
    fi

    # Recheck Vault pod status
    log "Rechecking Vault pod status after deployment..."
    sleep 3
    if ! check_vault_pod_status; then
      logError "Vault pod is still not running after deployment and retries. Cleaning up..."
      sleep 1
      clean_up_vault
      exit 1
    fi
  fi

  # Initialize Vault if not already initialized
  log "Checking if Vault is already initialized..."
  sleep 3
  VAULT_STATUS=$(kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault status -format=json | jq -r '.initialized')

  if [[ "$VAULT_STATUS" == "true" ]]; then
    log "Vault is already initialized."
  else
    log "Initializing Vault..."
    sleep 3

    # Try to initialize Vault and handle possible errors
    if kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault operator init -format=json > /tmp/vault-init.json; then
      logSuccess "Vault initialization succeeded."
    else
      logWarning "A problem occurred during initialization of Vault. Checking if Vault was initialized despite the error..."
      sleep 3

      # Check if Vault is initialized despite the error
      VAULT_STATUS=$(kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault status -format=json | jq -r '.initialized')
      if [[ "$VAULT_STATUS" == "true" ]]; then
        logError "Vault initialization was successful but writing to temp file failed. Resulting to cleaning up..."
        sleep 1
        clean_up_vault
        exit 1
      else
        log "Vault is not initialized. Retrying initialization..."
        sleep 3
        if ! kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault operator init -format=json > /tmp/vault-init.json; then
          logError "Vault initialization failed after retry."
          sleep 1
          clean_up_vault
          exit 1
        fi
      fi
    fi
  fi

  # Check if the vault-init.json file exists before proceeding
  if [[ -f /tmp/vault-init.json ]]; then
    log "Encrypting unseal keys..."
    sleep 3
    jq -r '.unseal_keys_b64[]' /tmp/vault-init.json | gpg --symmetric --cipher-algo AES256 -o ../vault-cred/unseal-keys.gpg || logError "Failed to encrypt unseal keys."
    jq -r '.root_token' /tmp/vault-init.json | gpg --symmetric --cipher-algo AES256 -o ../vault-cred/root-token.gpg || logError "Failed to encrypt root token."

    # Clean up temporary files
    rm /tmp/vault-init.json
  else
    logError "vault-init.json file not found. Resulting to deleting the faulty Vault instance..."
    sleep 1
    clean_up_vault
    exit 1
  fi

  # Unseal Vault 0
  unseal_vault "vault-0"

  # Joining other pods to Raft cluster
  join_pod_to_raft_cluster "vault-1"
  join_pod_to_raft_cluster "vault-2"

  # Unsealing Vault 1 and 2
  unseal_vault "vault-1"
  unseal_vault "vault-2"

  log "Decrypting root token..."
  sleep 3
  root_token=(gpg --decrypt ../vault-cred/root-token.gpg)
  if [[ $? ne 0]]; then
    logError "Failed to log in to Vault-o with root token. Cleaning up"
    sleep 1
    clean_up_vault
    exit 1
  fi

  log "Logging in to Vault with decrypted root token..."
  sleep 3
  if ! kubectl exec -it vault-0 -n "$NAMESPACE" -- vault login  -no-print "$root_token"
    logError "Failed to login to Vault-0 with decrypted root token"
    sleep 1
    clean_up_vault
    exit 1
  else
    logSuccess "Successfully logged into Vault-0 with decrypted root token"

  # Enable the KV secrets engine
  log "Enabling KV secrets engine..."
  sleep 3
  if ! kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault secrets enable -path=pesachain kv-v2; then
    logError "Failed to enable KV secrets engine."
    sleep 1
    clean_up_vault
    exit 1
  fi

  logSuccess "KV secrets engine successfully enabled"

  # Store initial secrets
  log "Storing CA admin's credentials..."
  sleep 3

  # Attempt to store CA admin's credentials
  if ! kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv put pesachain/org.pesachain.com/user/admin_creds \
    username="admin" \
    password="$(openssl rand -hex 24)"; then
    logError "Failed to store CA admin's credentials."
    sleep 1
    clean_up_vault
    exit 1
  fi

  # Store Auth0 secrets
  log "Storing Auth0 secrets..."
  sleep 3

  if ! error_message=$(kubectl exec -it VAULT-0 -n "$NAMESPACE" -- vault kv put pesachain/auth0 \
      domain="${AUTH0_DOMAIN}" \
      client_id="${AUTH0_CLIENT_ID}" \
      client_secret="${AUTH0_CLIENT_SECRET}" \
      client_audience="${AUTH0_CLIENT_AUDIENCE}" 2>&1); then
    exit_on_error "Failed to store Auth0 secrets into Vault- $error_message"
  fi

  logSuccess "Successfully stored Auth0 secrets into Vault."

  # Store certificates for OrdererOrg
  store_certificate "pesachain/orderer.pesachain.com/ca" "../crypto-config/ordererOrganizations/orderer.pesachain.com/ca/ca.orderer.pesachain.com-cert.pem" "../crypto-config/ordererOrganizations/orderer.pesachain.com/ca/priv_sk" "../crypto-config/ordererOrganizations/orderer.pesachain.com/ca/ca.orderer.pesachain.com-ca-chaincert.pem"

  # Store TLS certificates for OrdererOrg
  store_certificate "pesachain/orderer.pesachain.com/tlsca" "../crypto-config/ordererOrganizations/orderer.pesachain.com/tlsca/tlsca.orderer.pesachain.com-cert.pem" "../crypto-config/ordererOrganizations/orderer.pesachain.com/tlsca/priv_sk"

  # Store certificates for orderers (orderer0, orderer1, orderer2)
  store_certificate "pesachain/orderer.pesachain.com/orderers/orderer0.orderer.pesachain.com/msp" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer0.orderer.pesachain.com/msp/signcerts/orderer0.orderer.pesachain.com-cert.pem" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer0.orderer.pesachain.com/msp/keystore/priv_sk" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer0.orderer.pesachain.com/msp/cacerts/ca.orderer.pesachain.com-cert.pem"
  store_certificate "pesachain/orderer.pesachain.com/orderers/orderer1.orderer.pesachain.com/msp" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer1.orderer.pesachain.com/msp/signcerts/orderer1.orderer.pesachain.com-cert.pem" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer1.orderer.pesachain.com/msp/keystore/priv_sk" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer1.orderer.pesachain.com/msp/cacerts/ca.orderer.pesachain.com-cert.pem"
  store_certificate "pesachain/orderer.pesachain.com/orderers/orderer2.orderer.pesachain.com/msp" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer2.orderer.pesachain.com/msp/signcerts/orderer2.orderer.pesachain.com-cert.pem" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer2.orderer.pesachain.com/msp/keystore/priv_sk" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer2.orderer.pesachain.com/msp/cacerts/ca.orderer.pesachain.com-cert.pem"

  # Store TLS certificates for each orderer (orderer0, orderer1, orderer2)
  store_certificate "pesachain/orderer.pesachain.com/orderers/orderer0.orderer.pesachain.com/tls" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer0.orderer.pesachain.com/tls/server.crt" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer0.orderer.pesachain.com/tls/server.key" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer0.orderer.pesachain.com/tls/ca.crt"
  store_certificate "pesachain/orderer.pesachain.com/orderers/orderer1.orderer.pesachain.com/tls" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer1.orderer.pesachain.com/tls/server.crt" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer1.orderer.pesachain.com/tls/server.key" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer1.orderer.pesachain.com/tls/ca.crt"
  store_certificate "pesachain/orderer.pesachain.com/orderers/orderer2.orderer.pesachain.com/tls" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer2.orderer.pesachain.com/tls/server.crt" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer2.orderer.pesachain.com/tls/server.key" "../crypto-config/ordererOrganizations/orderer.pesachain.com/orderers/orderer2.orderer.pesachain.com/tls/ca.crt"

  # Store certificates for PeerOrg
  store_certificate "pesachain/peer.pesachain.com/ca" "../crypto-config/peerOrganizations/org.pesachain.com/ca/ca.org.pesachain.com-cert.pem" "../crypto-config/peerOrganizations/org.pesachain.com/ca/priv_sk" "../crypto-config/peerOrganizations/org.pesachain.com/ca/ca.org.pesachain.com-ca-chaincert.pem"

  # Store TLS certificates for PeerOrg
  store_certificate "pesachain/peer.pesachain.com/tlsca" "../crypto-config/peerOrganizations/org.pesachain.com/tlsca/tlsca.org.pesachain.com-cert.pem" "../crypto-config/peerOrganizations/org.pesachain.com/tlsca/priv_sk"

  # Store certificates for peers (peer0, peer1)
  store_certificate "pesachain/peer.pesachain.com/peers/peer0.peer.pesachain.com/msp" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer0.org.pesachain.com/msp/signcerts/peer0.org.pesachain.com-cert.pem" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer0.org.pesachain.com/msp/keystore/priv_sk" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer0.org.pesachain.com/msp/cacerts/ca.org.pesachain.com-cert.pem"
  store_certificate "pesachain/peer.pesachain.com/peers/peer1.peer.pesachain.com/msp" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer1.org.pesachain.com/msp/signcerts/peer1.org.pesachain.com-cert.pem" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer1.org.pesachain.com/msp/keystore/priv_sk" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer1.org.pesachain.com/msp/cacerts/ca.org.pesachain.com-cert.pem"

  # Store TLS certificates for each peer (peer0, peer1)
  store_certificate "pesachain/peer.pesachain.com/peers/peer0.peer.pesachain.com/tls" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer0.org.pesachain.com/tls/server.crt" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer0.org.pesachain.com/tls/server.key" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer0.org.pesachain.com/tls/ca.crt"
  store_certificate "pesachain/peer.pesachain.com/peers/peer1.peer.pesachain.com/tls" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer1.org.pesachain.com/tls/server.crt" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer1.org.pesachain.com/tls/server.key" "../crypto-config/peerOrganizations/org.pesachain.com/peers/peer1.org.pesachain.com/tls/ca.crt"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit 0
fi