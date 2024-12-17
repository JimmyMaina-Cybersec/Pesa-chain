#!/bin/bash

# Join bank-institution channel
# CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/bank1.com/users/Admin@bank1.com/msp
# CORE_PEER_ADDRESS=peer0.bank1.com:7051
# CORE_PEER_LOCALMSPID="Bank1MSP"
# CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/bank1.com/peers/peer0.bank1.com/tls/ca.crt

peer channel join -b bankinstitutions.block
peer channel update -o orderer0.pesachain.com:7050 -c bankinstitutions -f ./channel-artifacts/Bank1MSPanchors_bank-institutions.tx --tls --cafile $ORDERER_CA


# Join payment-gateways channel
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/pesachain.com/users/Admin@pesachain.com/msp
CORE_PEER_ADDRESS=peer0.pesachain.com:7051
CORE_PEER_LOCALMSPID="PesachainMSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/ca.crt

peer channel join -b paymentgateways.block
peer channel update -o orderer0.pesachain.com:7050 -c paymentgateways -f ./channel-artifacts/PesachainMSPanchors_payment-gateways.tx --tls --cafile $ORDERER_CA

# Repeat for other organizations and peers...