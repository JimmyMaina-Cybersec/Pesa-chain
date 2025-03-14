#!/usr/bin/env bash

cp ../orderer/payment-channel.tx .
export CORE_PEER_TLS_ENABLED=true
ORDERER_CA=${PWD}/../orderer/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem

export PEERS_PESACHAIN_TLS_FILES=${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers

export PEER0_PESACHAIN_CA=${PEERS_PESACHAIN_TLS_FILES}/peer0.pesachain.com/tls/ca.crt
export PEER1_PESACHAIN_CA=${PEERS_PESACHAIN_TLS_FILES}/peer1.pesachain.com/tls/ca.crt

export PEER0_PESACHAIN_TLS_KEY_FILE=${PEERS_PESACHAIN_TLS_FILES}/peer0.pesachain.com/tls/server.key
export PEER1_PESACHAIN_TLS_KEY_FILE=${PEERS_PESACHAIN_TLS_FILES}/peer1.pesachain.com/tls/server.key

export PEER0_PESACHAIN_TLS_CERT_FILE=${PEERS_PESACHAIN_TLS_FILES}/peer0.pesachain.com/tls/server.crt
export PEER1_PESACHAIN_TLS_CERT_FILE=${PEERS_PESACHAIN_TLS_FILES}/peer1.pesachain.com/tls/server.crt

export FABRIC_CFG_PATH=${PWD}/../config

export CHANNEL_NAME=payment-channel

setGlobalsForPeer0Pesachain() {
  export CORE_PEER_ID="peer0.pesachain.com"
  export CORE_PEER_LOCALMSPID="PesachainMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PESACHAIN_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/users/Admin@pesachain.com/msp
  export CORE_PEER_ADDRESS=peer0.pesachain.com:7051
  export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.pesachain.com:7051
  export CORE_PEER_TLS_CERT_FILE=$PEER0_PESACHAIN_TLS_CERT_FILE
  export CORE_PEER_TLS_KEY_FILE=$PEER0_PESACHAIN_TLS_KEY_FILE
  export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb0:5984
  export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
  export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
}

setGlobalsForPeer1Pesachain() {
  export CORE_PEER_ID="peer1.pesachain.com"
  export CORE_PEER_LOCALMSPID="PesachainMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_PESACHAIN_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/users/Admin@pesachain.com/msp
  export CORE_PEER_ADDRESS=peer1.pesachain.com:8051
  export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer1.pesachain.com:8051
  export CORE_PEER_TLS_CERT_FILE=$PEER1_PESACHAIN_TLS_CERT_FILE
  export CORE_PEER_TLS_KEY_FILE=$PEER1_PESACHAIN_TLS_KEY_FILE
  export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb1:5984
  export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
  export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
}

createChannel() {
  setGlobalsForPeer0Pesachain

  peer channel create -o ca.pesachain.com:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.com \
    -f ./${CHANNEL_NAME}.tx --outputBlock ./${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

joinChannel() {
  setGlobalsForPeer0Pesachain
  peer channel join -b ./$CHANNEL_NAME.block

  setGlobalsForPeer1Pesachain
  peer channel join -b ./$CHANNEL_NAME.block
}

updateAnchorPeers() {
  setGlobalsForPeer0Pesachain
  peer channel update -o ca.pesachain.com:7050 --ordererTLSHostnameOverride orderer.com \
    -c $CHANNEL_NAME -f ./${CORE_PEER_LOCALMSPID}anchors.tx \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

createChannel
sleep 2
joinChannel
sleep 2
updateAnchorPeers
