#!/bin/bash

CHAINCODE_NAME=$1
CHAINCODE_VERSION=$2
CHAINCODE_PATH=$3

# Package the chaincode
peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz \
    --path ${CHAINCODE_PATH} \
    --lang golang \
    --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION}

# Install chaincode on all peers
for org in pesachain; do
    for peer in 0 1; do
        export CORE_PEER_ADDRESS=peer${peer}.${org}.com:7051
        export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.com/users/Admin@${org}.com/msp
        export CORE_PEER_LOCALMSPID="${org}MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.com/peers/peer${peer}.${org}.com/tls/ca.crt

        peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
    done
done

# Approve chaincode for each org
for org in pesachain; do
    export CORE_PEER_ADDRESS=peer0.${org}.com:7051
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.com/users/Admin@${org}.com/msp
    export CORE_PEER_LOCALMSPID="${org}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.com/peers/peer0.${org}.com/tls/ca.crt

    peer lifecycle chaincode approveformyorg \
        -o orderer0.pesachain.com:7050 \
        --channelID paymentgateways \
        --name ${CHAINCODE_NAME} \
        --version ${CHAINCODE_VERSION} \
        --package-id ${CHAINCODE_NAME}_${CHAINCODE_VERSION} \
        --sequence 1 \
        --tls --cafile $ORDERER_CA
done

# Commit chaincode definition
peer lifecycle chaincode commit \
    -o orderer0.pesachain.com:7050 \
    --channelID paymentgateways \
    --name ${CHAINCODE_NAME} \
    --version ${CHAINCODE_VERSION} \
    --sequence 1 \
    --tls --cafile $ORDERER_CA