#!/usr/bin/env bash

# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="payment-channel"

echo $CHANNEL_NAME

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL -outputBlock ./genesis.block

# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./payment-channel.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ../Pesachain/PesachainMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PesachainMSP

echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ../org2/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

sleep 2

docker-compose -f docker-compose-orderer.yaml up -d

docker ps -a
