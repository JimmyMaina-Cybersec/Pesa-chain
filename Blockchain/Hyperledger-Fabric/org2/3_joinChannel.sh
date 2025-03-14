#!/usr/bin/env bash

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../orderer/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem

export PEERS_ORG2_TLS_FILES=${PWD}/crypto-config-ca/peerOrganizations/org2.example.com/peers

export PEER0_ORG2_CA=${PEERS_ORG2_TLS_FILES}/peer0.org2.example.com/tls/ca.crt
export PEER1_ORG2_CA=${PEERS_ORG2_TLS_FILES}/peer1.org2.example.com/tls/ca.crt

export PEER0_ORG2_TLS_KEY_FILE=${PEERS_ORG2_TLS_FILES}/peer0.org2.example.com/tls/server.key
export PEER1_ORG2_TLS_KEY_FILE=${PEERS_ORG2_TLS_FILES}/peer1.org2.example.com/tls/server.key

export PEER0_ORG2_TLS_CERT_FILE=${PEERS_ORG2_TLS_FILES}/peer0.org2.example.com/tls/server.crt
export PEER1_ORG2_TLS_CERT_FILE=${PEERS_ORG2_TLS_FILES}/peer1.org2.example.com/tls/server.crt

export FABRIC_CFG_PATH=${PWD}/../config

export CHANNEL_NAME=payment-channel

setGlobalsForPeer0Org2() {
  export CORE_PEER_ID="peer0.org2.example.com"
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config-ca/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
  export CORE_PEER_LISTENADDRESS=0.0.0.0:9051
  export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.example.com:9051
  export CORE_PEER_TLS_CERT_FILE=$PEER0_ORG2_TLS_CERT_FILE
  export CORE_PEER_TLS_KEY_FILE=$PEER0_ORG2_TLS_KEY_FILE
  export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb2:5984
  export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
  export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
}

setGlobalsForPeer1Org2() {
  export CORE_PEER_ID="peer1.org2.example.com"
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG2_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config-ca/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  export CORE_PEER_ADDRESS=peer1.org2.example.com:10051
  export CORE_PEER_LISTENADDRESS=0.0.0.0:10051
  export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer1.org2.example.com:10051
  export CORE_PEER_TLS_CERT_FILE=$PEER1_ORG2_TLS_CERT_FILE
  export CORE_PEER_TLS_KEY_FILE=$PEER1_ORG2_TLS_KEY_FILE
  export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb3:5984
  export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
  export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
}

fetchChannelBlock() {
  setGlobalsForPeer0Org2
  peer channel fetch 0 $CHANNEL_NAME.block -o ca.pesachain.com:7050 --ordererTLSHostnameOverride orderer.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
}
joinChannel() {
  setGlobalsForPeer0Org2
  peer channel join -b ./$CHANNEL_NAME.block

  setGlobalsForPeer1Org2
  peer channel join -b ./$CHANNEL_NAME.block
}

updateAnchorPeers() {

  setGlobalsForPeer0Org2
  peer channel update -o ca.pesachain.com:7050 --ordererTLSHostnameOverride orderer.com -c $CHANNEL_NAME -f ./${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

}
fetchChannelBlock
joinChannel
updateAnchorPeers
