#!/usr/bin/env bash

chaincodeInfo() {
  export CHANNEL_NAME="payment-channel"
  export CC_RUNTIME_LANGUAGE="golang"
  export CC_VERSION="1.0.3"
  export CC_SRC_PATH=../chaincodes/golang
  export CC_NAME="paymentccgo"
  export CC_SEQUENCE="3"

}
preSetupGO() {
  echo Vendoring Go dependencies ...
  pushd ../chaincodes/golang
  GO111MODULE=on go mod vendor
  popd
  echo Finished vendoring Go dependencies
}

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../orderer/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem
export PEERS_ORG2_TLS_FILES=${PWD}/../org2/crypto-config-ca/peerOrganizations/org2.example.com/peers
export PEER0_ORG2_CA=${PEERS_ORG2_TLS_FILES}/peer0.org2.example.com/tls/ca.crt
export PEER0_ORG2_TLS_KEY_FILE=${PEERS_ORG2_TLS_FILES}/peer0.org2.example.com/tls/server.key
export PEER0_ORG2_TLS_CERT_FILE=${PEERS_ORG2_TLS_FILES}/peer0.org2.example.com/tls/server.crt
export FABRIC_CFG_PATH=${PWD}/../config

setGlobalsForPeer0Org2() {
  export CORE_PEER_ID="peer0.org2.example.com"
  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/../org2/crypto-config-ca/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
  export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org2.example.com:9051
  export CORE_PEER_TLS_CERT_FILE=$PEER0_ORG2_TLS_CERT_FILE
  export CORE_PEER_TLS_KEY_FILE=$PEER0_ORG2_TLS_KEY_FILE
  export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb0:5984
  export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
  export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
}

packageChaincode() {

  rm -rf ${CC_NAME}.tar.gz

  peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${CC_VERSION}

}

installChaincode() {

  peer lifecycle chaincode install ${CC_NAME}.tar.gz

}

queryInstalled() {

  peer lifecycle chaincode queryinstalled >&log.txt

  cat log.txt

  PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)

  echo PackageID is ${PACKAGE_ID}
}
approveForMyOrg2() {

  peer lifecycle chaincode approveformyorg -o orderer.com:7050 --ordererTLSHostnameOverride orderer.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE}  --collections-config ${PWD}/../chaincodes/PDC/collection_config.json --init-required

}

checkCommitReadyness() {

  peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --sequence ${CC_SEQUENCE} --version ${CC_VERSION} --init-required --output json

}

insertTransaction() {
  echo "Invoking CreateTransaction with a sample payment transaction..."
  peer chaincode invoke \
    -o orderer.com:7050 \
    --ordererTLSHostnameOverride orderer.com \
    --tls --cafile $ORDERER_CA \
    -C $CHANNEL_NAME \
    -n ${CC_NAME} \
    --peerAddresses peer0.org2.example.com:9051 \
    --tlsRootCertFiles $PEER0_ORG2_CA \
    -c '{"Args":["CreateTransaction", "TXN102", "CreditCard", "John", "Doe", "200.0", "USD"]}'
  sleep 2
}

readTransaction() {
  echo "Reading transactions..."
  # Query all payment transactions from the public ledger.
  peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["QueryAllTransactions"]}'

  # Query a specific transaction by ID and transaction type.
  peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["QueryTransaction", "TXN102", "CreditCard"]}'
}

lifecycleCommands() {
  packageChaincode
  sleep 2
  installChaincode
  sleep 2
  queryInstalled
  sleep 2
  approveForMyOrg2
  sleep 2
  checkCommitReadyness
}
getInstallChaincodes() {

  peer lifecycle chaincode queryinstalled

}
preSetupGO
chaincodeInfo
setGlobalsForPeer0Org2
lifecycleCommands
insertTransaction
readTransaction
getInstallChaincodes
