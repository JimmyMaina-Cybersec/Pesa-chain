#!/bin/bash
set -e

# Base directories for peers and orderers
PEERS_DIR="./organizations/peerOrganizations/pesachain.com/peers"
ORDERERS_DIR="./organizations/ordererOrganizations/orderer.com"

# Function to remove TLS files from an entity's tls directory
remove_tls_files() {
    local ENTITY_DIR="$1"
    local TLS_DIR="$ENTITY_DIR/tls"
    if [ -d "$TLS_DIR" ]; then
        echo "Removing TLS files in $TLS_DIR"
        rm -f "$TLS_DIR/server.crt" "$TLS_DIR/server.key" "$TLS_DIR/ca.crt"
        # Optionally, remove the TLS directory if it is now empty:
        rmdir "$TLS_DIR" 2>/dev/null && echo "Removed empty directory: $TLS_DIR" || echo "Left non-empty directory: $TLS_DIR"
    else
        echo "No TLS directory found in $ENTITY_DIR, skipping..."
    fi
}

# Process peer entities
if [ -d "$PEERS_DIR" ]; then
    echo "Processing peers in $PEERS_DIR"
    for peer in "$PEERS_DIR"/*; do
        if [ -d "$peer" ]; then
            remove_tls_files "$peer"
        fi
    done
else
    echo "Peers directory not found: $PEERS_DIR"
fi

# Process orderer entities
if [ -d "$ORDERERS_DIR" ]; then
    echo "Processing orderers in $ORDERERS_DIR"
    for orderer in "$ORDERERS_DIR"/*; do
        if [ -d "$orderer" ]; then
            remove_tls_files "$orderer"
        fi
    done
else
    echo "Orderers directory not found: $ORDERERS_DIR"
fi

echo "Removal of copied TLS files complete."
