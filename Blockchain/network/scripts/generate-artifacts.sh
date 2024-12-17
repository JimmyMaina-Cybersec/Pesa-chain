#!/bin/bash

# Generate crypto materials
cryptogen generate --config=./crypto-config.yaml

# Create genesis block for orderer
configtxgen -profile OrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block

# Create channel transactions
configtxgen -profile BankInstitutionChannel -outputCreateChannelTx ./channel-artifacts/bank-institutions.tx -channelID bankinstitutions
configtxgen -profile PaymentGatewaysChannel -outputCreateChannelTx ./channel-artifacts/payment-gateways.tx -channelID paymentgateways

# Generate anchor peer updates for each org


configtxgen -profile PaymentGatewaysChannel -outputAnchorPeersUpdate ./channel-artifacts/PesachainMSPanchors_payment-gateways.tx -channelID paymentgateways -asOrg PesachainMSP
