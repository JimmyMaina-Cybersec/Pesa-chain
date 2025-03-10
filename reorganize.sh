#!/bin/bash
set -e

# Base directories for peers and orderers:
PEERS_DIR="./organizations/peerOrganizations/pesachain.com/peers"
ORDERERS_DIR="./organizations/ordererOrganizations/orderer.com"

# Function to reorganize TLS for an entity by moving files from tls subdirectories
reorganize_entity_tls() {
    local ENTITY_DIR="$1"
    echo "Reorganizing TLS for $ENTITY_DIR"

    TLS_DIR="$ENTITY_DIR/tls"

    if [ ! -d "$TLS_DIR" ]; then
      echo "  TLS directory does not exist in $ENTITY_DIR. Skipping."
      return
    fi

    # Move TLS CA certificate from tls/tlscacerts to tls/ca.crt
    if [ -d "$TLS_DIR/tlscacerts" ]; then
      CA_CERT=$(find "$TLS_DIR/tlscacerts" -type f | head -n 1)
      if [ -n "$CA_CERT" ]; then
         mv -f "$CA_CERT" "$TLS_DIR/ca.crt"
         echo "  Moved CA cert from $CA_CERT to $TLS_DIR/ca.crt"
      else
         echo "  No TLS CA certificate found in $TLS_DIR/tlscacerts"
      fi
      rm -rf "$TLS_DIR/tlscacerts"
    else
      echo "  Directory $TLS_DIR/tlscacerts does not exist"
    fi

    # Move server certificate from tls/signcerts to tls/server.crt
    if [ -d "$TLS_DIR/signcerts" ]; then
      SERVER_CERT=$(find "$TLS_DIR/signcerts" -type f | head -n 1)
      if [ -n "$SERVER_CERT" ]; then
         mv -f "$SERVER_CERT" "$TLS_DIR/server.crt"
         echo "  Moved server cert from $SERVER_CERT to $TLS_DIR/server.crt"
      else
         echo "  No server certificate found in $TLS_DIR/signcerts"
      fi
      rm -rf "$TLS_DIR/signcerts"
    else
      echo "  Directory $TLS_DIR/signcerts does not exist"
    fi

    # Move server key from tls/keystore to tls/server.key
    if [ -d "$TLS_DIR/keystore" ]; then
      SERVER_KEY=$(find "$TLS_DIR/keystore" -type f | head -n 1)
      if [ -n "$SERVER_KEY" ]; then
         mv -f "$SERVER_KEY" "$TLS_DIR/server.key"
         echo "  Moved server key from $SERVER_KEY to $TLS_DIR/server.key"
      else
         echo "  No server key found in $TLS_DIR/keystore"
      fi
      rm -rf "$TLS_DIR/keystore"
    else
      echo "  Directory $TLS_DIR/keystore does not exist"
    fi
}

# Process peer entities
if [ -d "$PEERS_DIR" ]; then
  echo "Processing peers in $PEERS_DIR"
  for peer in "$PEERS_DIR"/*; do
    if [ -d "$peer" ]; then
       reorganize_entity_tls "$peer"
    fi
  done
else
  echo "Peers directory $PEERS_DIR does not exist."
fi

# Process orderer entities
if [ -d "$ORDERERS_DIR" ]; then
  echo "Processing orderers in $ORDERERS_DIR"
  for orderer in "$ORDERERS_DIR"/*; do
    if [ -d "$orderer" ]; then
       reorganize_entity_tls "$orderer"
    fi
  done
else
  echo "Orderers directory $ORDERERS_DIR does not exist."
fi

echo "TLS reorganization complete."
