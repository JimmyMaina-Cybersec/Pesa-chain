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

# Function to clean up the Vault namespace and associated resources
clean_up_vault() {
  log "Starting cleanup process..."
  sleep 2

  # 1. Uninstall the Vault Helm release (this should delete Vault pods)
  if helm list -n "$NAMESPACE" | grep -q "^vault"; then
    log "Uninstalling Helm release 'vault'..."
    helm uninstall vault --namespace "$NAMESPACE" || logError "Failed to uninstall Helm release 'vault'."
    logSuccess "Helm release 'vault' uninstalled successfully."
  else
    log "Helm release 'vault' not found in namespace $NAMESPACE."
  fi

  sleep 3

  # 2. Ensure Vault pods are deleted (use a label selector appropriate to your deployment)
  if kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=vault &> /dev/null; then
    log "Deleting any remaining Vault pods..."
    kubectl delete pod -l app.kubernetes.io/name=vault -n "$NAMESPACE" --wait --timeout=60s || logWarning "Vault pods did not terminate within the timeout."
  else
    log "No Vault pods found in namespace $NAMESPACE."
  fi

  sleep 3

  # 3. Delete all Persistent Volume Claims in the namespace
  if kubectl get pvc -n "$NAMESPACE" &> /dev/null; then
    log "Deleting Persistent Volume Claims (PVCs) in namespace $NAMESPACE..."
    kubectl delete pvc --all -n "$NAMESPACE" --wait || logError "Failed to delete PVCs in namespace $NAMESPACE."
    kubectl wait --for=delete pvc --all -n "$NAMESPACE" --timeout=60s || logError "PVCs were not deleted in namespace $NAMESPACE within the timeout."
  else
    log "No Persistent Volume Claims (PVCs) found in namespace $NAMESPACE."
  fi

  sleep 3

  # 4. Delete ClusterRoles and ClusterRoleBindings associated with Vault
  if kubectl get clusterrole vault-agent-injector-clusterrole &> /dev/null; then
    log "Deleting ClusterRole vault-agent-injector-clusterrole..."
    kubectl delete clusterrole vault-agent-injector-clusterrole || logError "Failed to delete ClusterRole vault-agent-injector-clusterrole."
    kubectl wait --for=delete clusterrole vault-agent-injector-clusterrole --timeout=60s || logError "ClusterRole vault-agent-injector-clusterrole was not deleted within the timeout."
  else
    log "ClusterRole vault-agent-injector-clusterrole not found."
  fi

  if kubectl get clusterrolebinding vault-agent-injector-binding &> /dev/null; then
    log "Deleting ClusterRoleBinding vault-agent-injector-binding..."
    kubectl delete clusterrolebinding vault-agent-injector-binding || logError "Failed to delete ClusterRoleBinding vault-agent-injector-binding."
    kubectl wait --for=delete clusterrolebinding vault-agent-injector-binding --timeout=60s || logError "ClusterRoleBinding vault-agent-injector-binding was not deleted within the timeout."
  else
    log "ClusterRoleBinding vault-agent-injector-binding not found."
  fi

  sleep 3

  # 5. Delete any lingering Helm release secrets from kube-system
  if kubectl get secrets -n kube-system | grep -q "^sh.helm.release.v1.vault"; then
    log "Deleting Helm release secrets..."
    secrets=$(kubectl get secrets -n kube-system | grep "^sh.helm.release.v1.vault" | awk '{print $1}')
    if [[ -n "$secrets" ]]; then
      kubectl delete secret -n kube-system $secrets || logError "Failed to delete Helm release secrets."
    else
      logWarning "No matching Helm release secrets found after filtering."
    fi
  else
    log "Helm release secrets not found in kube-system."
  fi

  sleep 3

  # 6. Finally, delete the namespace (which removes any leftover namespaced resources)
  if kubectl get namespace "$NAMESPACE" &> /dev/null; then
    log "Deleting namespace $NAMESPACE..."
    kubectl delete namespace "$NAMESPACE" --wait --timeout=60s || logWarning "Initial delete attempt for namespace $NAMESPACE failed. Retrying..."
    for attempt in {1..5}; do
      kubectl delete namespace "$NAMESPACE" --ignore-not-found=true &> /dev/null
      if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        logSuccess "Namespace $NAMESPACE successfully deleted."
        break
      else
        logWarning "Retry $attempt: Namespace $NAMESPACE still exists. Waiting..."
        sleep 3
      fi
      if [[ $attempt -eq 5 ]]; then
        logError "Failed to delete namespace $NAMESPACE after 5 attempts."
        sleep 1
        exit 1
      fi
    done
  else
    log "Namespace $NAMESPACE not found. Skipping namespace deletion."
  fi

  logSuccess "Cleanup completed."
  sleep 1
}

# Function to insert data into MongoDB
# mongo_insert() {
#   local key=$1
#   local value=$2
#   local json_doc="{\"key\":\"$key\", \"value\":\"$value\"}"

#   # Attempt to insert
#   result=$(echo "db.BackupCertsAndCreds.insertOne($json_doc)" | mongosh "${MONGO_URI}" 2>&1)
#   if [[ $? -eq 0 ]]; then
#     logSuccess "Successfully backed up $key to MongoDB."
#   else
#     logWarning "Failed to back up $key to MongoDB. Error: $result"
#   fi
# }

# Function to check if a certificate exists in Vault before backing up
check_and_store_certificate() {
  local vault_path=$1
  if kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv get -format=json "$vault_path" > /dev/null 2>&1; then
    logSuccess "Found $vault_path in Vault. Retrieving and storing in MongoDB..."
    sleep 3
    cert_data=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv get -format=json "$vault_path" | jq -r '.data.data')
    mongo_insert "$vault_path" "$cert_data"
  else
    error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv get -format=json "$vault_path" 2>&1)
    logWarning "$vault_path not found in Vault. Skipping its backup. Error: $error_message"
  fi
}

# Function to back up certificates from Vault to MongoDB
backup_certificates() {
  vault_paths=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv list -format=json "pesachain" 2>/dev/null | jq -r '.[]')
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
  auth0_paths=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv list -format=json "pesachain/auth0" | jq -r '.[]')

  if [[ -z "$auth0_paths" ]]; then
    logWarning "No Auth0 secrets found under 'pesachain/auth0'. Skipping backup."
    return
  fi

  for auth0_secret in $auth0_paths; do
    full_auth0_path="pesachain/auth0/$auth0_secret"
    if kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv get -format=json "$full_auth0_path" > /dev/null 2>&1; then
      secret_data=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv get -format=json "$full_auth0_path" | jq -r '.data.data')
      mongo_insert "$full_auth0_path" "$secret_data"
    else
      logWarning "Failed to retrieve Auth0 secret: $auth0_secret. Skipping..."
      sleep 1
    fi
  done

  logSuccess "Auth0 secrets backup to MongoDB completed."
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
    NAMESPACE
  )

  log "Ensuring all required environment variables are set..."
  sleep 3
  for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then # indirect expansion
      logError "Missing environment variable: $var"
      exit 1
    fi
  done

  # log "Checking if MongoDB client (mongosh) is installed..."
  # sleep 3
  # if ! command -v mongosh &> /dev/null; then
  #   logError "MongoDB client (mongosh) is not installed or not in PATH. Aborting operation."
  #   exit 1
  # fi

  # log "Verifying MongoDB server is accessible..."
  # if ! mongosh "${MONGO_URI}" --eval "db.runCommand({ ping: 1 })" &> /dev/null; then
  #   logError "MongoDB server is not accessible. Please check if it's running and accessible at ${MONGO_URI}."
  #   exit 1
  # fi

  logSuccess "All environment variables are set."
}

# Function to check status of all Vault pods in the HA Raft cluster
check_vault_pod_status() {
  for i in $(seq 1 "$MAX_RETRIES"); do
    # Get the list of Vault pods dynamically
    PODS=($(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=vault --output=jsonpath='{.items[*].metadata.name}'))

    if [[ ${#PODS[@]} -eq 0 ]]; then
      logWarning "There are no vault pods running. Proceeding to deploy..."
      return false
    fi

    all_running=true

    for pod in "${PODS[@]}"; do
      POD_STATUS=$(kubectl get pod "$pod" -n "$NAMESPACE" --output=jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")

      if [[ "$POD_STATUS" == "Running" ]]; then
        logSuccess "Vault pod $pod is running."
      elif [[ "$POD_STATUS" == "NotFound" ]]; then
        logWarning "Vault pod $pod not found. It may still be initializing."
        all_running=false
      else
        logWarning "Vault pod $pod is not running yet. Current status: $POD_STATUS."
        all_running=false
      fi
    done

    if $all_running; then
      logSuccess "All Vault pods are running."
      return 0
    else
      logWarning "Not all Vault pods are running. Retrying ($i/$MAX_RETRIES)..."
      sleep "$RETRY_DELAY"
    fi
  done

  logWarning "Some Vault pods are still not running after $MAX_RETRIES attempts. Deleting faulty pods before proceeding..."
  sleep 1
  clean_up_vault
  exit 1
}

# Fnction to unseal vault pods
unseal_vault() {
  local pod_name="$1"
  log "Unsealing $pod_name..."
  sleep 3
  for i in {1..3}; do
    # Decrypt the unseal key
    KEY=$(gpg --decrypt ../Vault/vault-cred/unseal-keys.gpg | sed -n "${i}p")
    if [[ $? -ne 0 ]]; then
      logError "Failed to decrypt unseal key $i for $pod_name. Cleaning up..."
      sleep 1
      clean_up_vault
      exit 1
    fi

    # Unseal the vault pod
    kubectl exec $pod_name -n "$NAMESPACE" -- vault operator unseal "$KEY"
    if [[ $? -ne 0 ]]; then
      logError "Failed to unseal $pod_name with key $i. Cleaning up..."
      sleep 1
      clean_up_vault
      exit 1
    fi
  done
  logSuccess "$pod_name successfully unsealed"
}

# Function to join vault pods to raft
join_pod_to_raft_cluster() {
  local pod_name=$1

  # Retrieve the leader's API address dynamically
  set +e
  leader_address=$(kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault status -format=json | jq -r '.leader_address')
  set -e
  if [ -z "$leader_address" ]; then
    logError "Failed to retrieve leader address."
    sleep 1
    clean_up_vault
    exit 1
  fi

  log "Joining pod $pod_name to raft cluster..."
  sleep 3
  if ! kubectl exec $pod_name -- vault operator raft join "$leader_address"; then
    logError "Failed to join $pod_name to raft cluster."
    sleep 1
    clean_up_vault
    exit 1
  else
    logSuccess "$pod_name successfully joined the raft cluster"
  fi
  sleep 1

  unseal_vault "$pod_name"
}

# Configure Vault Kubernetes Auth Method and Roles
configure_vault_kubernetes_auth() {
  log "Configuring Vault to use Kubernetes authentication..."
  sleep 2

  # Enable Kubernetes Auth
  if ! kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault auth enable kubernetes; then
    logError "Failed to enable Kubernetes auth method in Vault."
    sleep 1
    clean_up_vault
    exit 1
  fi
  logSuccess "Kubernetes auth method enabled successfully."

  # Configure Kubernetes Auth
  if ! kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault write auth/kubernetes/config \
      kubernetes_host="$KUBERNETES_HOST" \
      token_reviewer_jwt="$TOKEN_REVIEWER_JWT" \
      kubernetes_ca_cert="$KUBERNETES_CA_CERT" \
      issuer="$ISSUER"; then
    logError "Failed to configure Kubernetes auth method in Vault."
    sleep 1
    clean_up_vault
    exit 1
  fi
  logSuccess "Vault Kubernetes authentication configured successfully."

  # Configure Kubernetes Auth Role
  log "Configuring Kubernetes authentication roles in Vault..."
  sleep 2

  ROLE_NAME="vault-app"
  BOUND_SERVICE_ACCOUNT="vault-auth"
  NAMESPACE_TO_BIND="default"
  POLICIES="default,read-secrets"
  TTL="1h"

  if ! kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault write auth/kubernetes/role/$ROLE_NAME \
      bound_service_account_names="$BOUND_SERVICE_ACCOUNT" \
      bound_service_account_namespaces="$NAMESPACE_TO_BIND" \
      policies="$POLICIES" \
      ttl="$TTL"; then
    logError "Failed to configure Kubernetes auth role '$ROLE_NAME' in Vault."
    sleep 1
    clean_up_vault
    exit 1
  fi

  logSuccess "Vault Kubernetes authentication role '$ROLE_NAME' configured successfully."
}

main() {
  # Exit immediately if a command exits with a non-zero status
  # Ensure that the entire pipe fails if any command fails
  set -eE
  trap 'logError "Error: Command \"$BASH_COMMAND\" failed with exit code $?;"' ERR
  set -o pipefail

  # Error Log Redirection
  exec 2>>/tmp/vault-error.log

  # Set default values or override from environment variables or command-line args
  NAMESPACE="${NAMESPACE:-vault}"
  VAULT_POD="vault-0"
  MAX_RETRIES=50
  RETRY_DELAY=10

  # Load the configuration file
  log "Loading configuration files..."
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
    echo "VAULT_POD=${VAULT_POD}"
    sleep 0.8
    echo
  else
    logError "Configuration file .env not found."
    exit 1
  fi

  # Check if required environment variables are set
  validate_env_vars

  # Ensure that the Vault pod is running
  log "Checking if the Vault pods are running..."
  sleep 3

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

    # Deploy or upgrade Vault with HA and integrated Raft storage (3 nodes)
    if helm list -n "$NAMESPACE" | grep -q '^vault'; then
      log "Vault release exists. Attempting to upgrade..."
      sleep 3
      echo
      if ! error_message=$(helm upgrade vault hashicorp/vault \
          --namespace "$NAMESPACE" \
          --dry-run --debug \
          --values helm-vault-raft-values.yaml 2>&1); then
        logWarning "Failed to upgrade Vault release - $error_message. Deleting and redeploying..."
        sleep 3
        if ! helm uninstall vault --namespace "$NAMESPACE"; then
          logError "Failed to delete Vault release. Kindly investigate. Exiting..."
          sleep 1
          exit 1
        fi
        if ! helm install vault hashicorp/vault \
            --namespace "$NAMESPACE" \
            --create-namespace \
            --values helm-vault-raft-values.yaml; then
          logError "Failed to deploy Vault using Helm. Exiting..."
          sleep 1
          exit 1
        fi
      else
        logSuccess "Vault release upgraded successfully."
      fi
    else
      echo
      log "Deploying Vault using Helm..."
      sleep 3
      echo
      if ! error_message=$(helm install vault hashicorp/vault \
          --namespace "$NAMESPACE" \
          --create-namespace \
          --values ../Vault/Raft-config/helm-vault-raft-values.yaml 2>&1); then
        logError "Failed to deploy Vault using Helm. Error: $error_message"
        sleep 1
        exit 1
      fi
    fi

    # Recheck Vault pod status
    log "Rechecking Vault pod status after deployment..."
    sleep 3
    while ! check_vault_pod_status; do
      sleep 3
    done
  fi

  pods=($(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=vault --output=jsonpath='{.items[*].metadata.name}'))
  vault_pod0=${pods[0]}
  vault_pod1=${pods[1]}
  vault_pod2=${pods[2]}

  log $vault_pod0
  log $vault_pod1
  log $vault_pod2
  echo
  read

  # Initialize Vault if not already initialized
  log "Checking if Vault is already initialized..."
  sleep 3
  # Capture and print the output and errors of the kubectl exec command
  set +e
  VAULT_STATUS=$(kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault status -format=json 2>/dev/null | jq -r '.initialized')
  set -e

  if [[ "$VAULT_STATUS" == "true" ]]; then
    log "Vault is already initialized."
  else
    log "Initializing Vault..."
    sleep 3

    # Try to initialize Vault and handle possible errors
    if kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault operator init -format=json > /tmp/vault-init.json; then
      logSuccess "Vault initialization succeeded."
    else
      logWarning "A problem occurred during initialization of Vault. Checking if Vault was initialized despite the error..."
      sleep 3

      # Check if Vault is initialized despite the error
      set +e
      VAULT_STATUS=$(kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault status -format=json | jq -r '.initialized')
      set -e
      if [[ "$VAULT_STATUS" == "true" ]]; then
        logError "Vault initialization was successful but writing to temp file failed. Resulting to cleaning up..."
        sleep 1
        clean_up_vault
        exit 1
      else
        log "Vault is not initialized. Retrying initialization..."
        sleep 3
        if ! kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault operator init -format=json > /tmp/vault-init.json; then
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
    cat /tmp/vault-init.json
    log "Encrypting unseal keys..."
    sleep 3
    jq -r '.unseal_keys_b64[]' /tmp/vault-init.json | gpg --symmetric --cipher-algo AES256 -o ../Vault/vault-cred/unseal-keys.gpg || logError "Failed to encrypt unseal keys."
    jq -r '.root_token' /tmp/vault-init.json | gpg --symmetric --cipher-algo AES256 -o ../Vault/vault-cred/root-token.gpg || logError "Failed to encrypt root token."

    # Clean up temporary files
    rm /tmp/vault-init.json
  else
    logError "vault-init.json file not found. Resulting to deleting the faulty Vault instance..."
    sleep 1
    clean_up_vault
    exit 1
  fi

  # Joining other pods to Raft cluster
  join_pod_to_raft_cluster "$vault_pod0"
  join_pod_to_raft_cluster "$vault_pod1"
  join_pod_to_raft_cluster "$vault_pod2"

  read

  # Retrieve Kubernetes authentication details
  log "Retrieving Kubernetes authentication details..."
  sleep 2

  # Kubernetes host
  KUBERNETES_HOST=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
  logSuccess "Kubernetes host: $KUBERNETES_HOST"

  # Token reviewer JWT
  TOKEN_REVIEWER_JWT=$(kubectl exec "$vault_pod0" -n "$NAMESPACE" -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  logSuccess "Token reviewer JWT retrieved successfully."

  # Kubernetes CA cert
  KUBERNETES_CA_CERT=$(kubectl exec "$vault_pod0" -n "$NAMESPACE" -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 | tr -d '\n')
  logSuccess "Kubernetes CA certificate retrieved and encoded in base64."

  # Issuer
  ISSUER=$(kubectl exec "$vault_pod0" -n "$NAMESPACE" -- cat /var/run/secrets/kubernetes.io/serviceaccount/token | \
    jq -R 'split(".") | .[1] | @base64d | fromjson.iss' 2>/dev/null || echo "https://kubernetes.default.svc.cluster.local")
  logSuccess "Kubernetes issuer: $ISSUER"

  configure_vault_kubernetes_auth

  # log "Decrypting root token..."
  # sleep 3
  # root_token=(gpg --decrypt ../Vault/vault-cred/root-token.gpg)
  # if [[ $? -ne 0 ]]; then
  #   logError "Failed to log in to Vault-o with root token. Cleaning up"
  #   sleep 1
  #   clean_up_vault
  #   exit 1
  # fi

  # log "Logging in to Vault with decrypted root token..."
  # sleep 3
  # if ! error_message=$(kubectl exec "$vault_pod0" -n "$NAMESPACE" -- vault login  -no-print "$root_token"); then
  #   logError "Failed to login to Vault-0 with decrypted root token- $error_message"
  #   sleep 1
  #   clean_up_vault
  #   exit 1
  # else
  #   logSuccess "Successfully logged into Vault-0 with decrypted root token"
  # fi

  # Enable the KV secrets engine
  log "Enabling KV secrets engine..."
  sleep 3
  if ! error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault secrets enable -path=pesachain_kv kv-v2); then
    logError "Failed to enable KV secrets engine- $error_message"
    sleep 1
    clean_up_vault
    exit 1
  fi
  logSuccess "KV secrets engine successfully enabled"

  # Store Pesachain cert in KV engine
  log "Storing Pesachain cert in KV engine..."
  sleep 3
  if ! error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv put pesachain_kv/cert certificate=@../crypto-config/peerOrganizations/ca/pesachainCA.crt); then
    logError "Failed to store Pesachain cert in KV engine- $error_message"
      sleep 1
      clean_up_vault
      exit 1
  fi

  # Enable the PKI secrets engine
  log "Enabling PKI secrets engine..."
  sleep 3
  if ! error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault secrets enable -path=pesachain_pki pki); then
    logError "Failed to enable PKI secrets engine- $error_message"
    sleep 1
    clean_up_vault
    exit 1
  fi
  logSuccess "PKI secrets engine successfully enabled"

  log "Setting up pki engine..."
  sleep 3

  # Increasing the global TTL for the pki engine
  if ! error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault secrets tune -max-lease-ttl=87648h pesachain_pki); then # TTL=10 years
    logError "Failed to set max TTL for PKI engine- $error_message"
    sleep 1
    clean_up_vault
    exit 1
  fi
  logSuccess "PKI global max TTL set to 10 years"

  # Configuring Vault to trust pesachain certificate (intermediate cert)
  # ...but first, retrieve PesachaCA cert from Pesachain's KV engine
  if ! pesachainCACert_content=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault read -field=certificate pesachain_kv/cert); then
    logError "Failed to retrieve Pesachain CA certificate from KV engine, cleaning up and exiting"
    sleep 1
    clean_up_vault
    exit 1
  fi

  # Trusting Pesachain certificate
  if ! error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault write pesachain_pki/config/ca pem_bundle="$pesachainCACert_content"); then
    logError "Failed to trust pesachain certificate- $error_message"
    sleep 1
    clean_up_vault
    exit 1
  fi
  logSuccess "Configuring Pesachain CA trust successful."

  # Configuring CRL location and issuing certificates
  if ! error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault write pesachain_pki/config/urls \
    issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
    crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"); then
    logError "Failed to configure CRL location and issuing certificates."
    sleep 1
    clean_up_vault
    exit 1
  fi
  logSuccess "Successfully configured CRL location and issuing certificates"

  # Configuring roles
  if ! error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault write pesachain_pki/roles/new_organizations \
    allowed_domains="financial_institutions.com,payment_gateway.com" \
    allow_subdomains=true \
    allow_any_name=false \
    server_flag=false \
    client_flag=false \
    max_ttl=8760h \
    key_usage="DigitalSignature,KeyEncipherment,CertSign" \
    organization="Pesachain_fabric"
  ); then
   logError "Failed to configure roles- $error_message"
    sleep 1
    clean_up_vault
    exit 1
  fi
  logSuccess "Successfully configured roles"

  # Store Auth0 secrets
  log "Storing Auth0 secrets..."
  sleep 3

  if ! error_message=$(kubectl exec "$VAULT_POD" -n "$NAMESPACE" -- vault kv put pesachain/auth0 \
      domain="${AUTH0_DOMAIN}" \
      client_id="${AUTH0_CLIENT_ID}" \
      client_secret="${AUTH0_CLIENT_SECRET}" \
      client_audience="${AUTH0_CLIENT_AUDIENCE}" 2>&1); then
    exit_on_error "Failed to store Auth0 secrets into Vault- $error_message"
  fi

  logSuccess "Successfully stored Auth0 secrets into Vault."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit 0
fi