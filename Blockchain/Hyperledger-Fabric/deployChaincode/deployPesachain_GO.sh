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
export PEERS_PESACHAIN_TLS_FILES=${PWD}/../Pesachain/crypto-config-ca/peerOrganizations/pesachain.com/peers
export PEER0_PESACHAIN_CA=${PEERS_PESACHAIN_TLS_FILES}/peer0.pesachain.com/tls/ca.crt
export PEER0_PESACHAIN_TLS_KEY_FILE=${PEERS_PESACHAIN_TLS_FILES}/peer0.pesachain.com/tls/server.key
export PEER0_PESACHAIN_TLS_CERT_FILE=${PEERS_PESACHAIN_TLS_FILES}/peer0.pesachain.com/tls/server.crt
export FABRIC_CFG_PATH=${PWD}/../config

setGlobalsForPeer0Pesachain() {
  export CORE_PEER_ID="peer0.pesachain.com"
  export CORE_PEER_LOCALMSPID="PesachainMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PESACHAIN_CA
  export CORE_PEER_MSPCONFIGPATH=${PWD}/../Pesachain/crypto-config-ca/peerOrganizations/pesachain.com/users/Admin@pesachain.com/msp
  export CORE_PEER_ADDRESS=peer0.pesachain.com:7051
  export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.pesachain.com:7051
  export CORE_PEER_TLS_CERT_FILE=$PEER0_PESACHAIN_TLS_CERT_FILE
  export CORE_PEER_TLS_KEY_FILE=$PEER0_PESACHAIN_TLS_KEY_FILE
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
approveForMyPesachain() {

  setGlobalsForPeer0Pesachain

  peer lifecycle chaincode approveformyorg -o orderer.com:7050 --ordererTLSHostnameOverride orderer.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE}  --collections-config ${PWD}/../chaincodes/PDC/collection_config.json --init-required

}

getblock() {
  peer channel getinfo -c payment-channel -o orderer.com:7050 --ordererTLSHostnameOverride orderer.com --tls --cafile $ORDERER_CA
}

checkCommitReadyness() {

  peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --sequence ${CC_SEQUENCE} --version ${CC_VERSION} --init-required --output json

}
commitChaincodeDefination() {

  peer lifecycle chaincode commit -o orderer.com:7050 --ordererTLSHostnameOverride orderer.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --peerAddresses peer0.pesachain.com:7051 --tlsRootCertFiles $PEER0_PESACHAIN_CA --sequence ${CC_SEQUENCE} --version ${CC_VERSION} --collections-config ${PWD}/../chaincodes/PDC/collection_config.json --init-required

}

queryCommitted() {

  peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} --output json

}
chaincodeInvokeInit() {

  peer chaincode invoke -o orderer.com:7050 --ordererTLSHostnameOverride orderer.com --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME -n ${CC_NAME} --peerAddresses peer0.pesachain.com:7051 --tlsRootCertFiles $PEER0_PESACHAIN_CA --isInit -c '{"function": "InitLedger","Args":[]}'

}

insertTransaction() {
  echo "Invoking CreateTransaction with a sample payment transaction..."
  peer chaincode invoke \
    -o orderer.com:7050 \
    --ordererTLSHostnameOverride orderer.com \
    --tls --cafile $ORDERER_CA \
    -C $CHANNEL_NAME \
    -n ${CC_NAME} \
    --peerAddresses peer0.pesachain.com:7051 \
    --tlsRootCertFiles $PEER0_PESACHAIN_CA \
    -c '{"Args":["CreateTransaction", "TXN101", "EFT", "Alice", "Bob", "150.0", "USD"]}'
  sleep 2
}

readTransaction() {
  echo "Reading transactions..."

  # Query all payment transactions
  peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["QueryAllTransactions"]}'

  # Query a specific transaction by Id and transaction type (non-sensitive, e.g., "EFT")
  peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["QueryTransaction", "TXN101", "EFT"]}'
}

lifecycleCommands() {
  echo "CC_SEQUENCE is $CC_SEQUENCE"
  packageChaincode
  sleep 2
  installChaincode
  sleep 2
  queryInstalled
  sleep 2
  approveForMyPesachain
  sleep 2
  getblock
  checkCommitReadyness
  sleep 2
  commitChaincodeDefination
  sleep 2
  queryCommitted
  sleep 2
  chaincodeInvokeInit
  sleep 10
}
getInstallChaincodes() {

  peer lifecycle chaincode queryinstalled

}

preSetupGO
chaincodeInfo
setGlobalsForPeer0Pesachain
lifecycleCommands
insertTransaction
readTransaction
getInstallChaincodes
