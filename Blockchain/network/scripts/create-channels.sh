#!/bin/bash

# Create channels
log "Creating channels..."
peer channel create -o orderer.pesachain.com:7050 -c bankinstitutionchannel -f ./channel-artifacts/bankinstitutionchannel.tx --outputBlock ./channel-artifacts/bankinstitutionchannel.block
peer channel create -o orderer.pesachain.com:7050 -c paymentgatewayschannel -f ./channel-artifacts/paymentgatewayschannel.tx --outputBlock ./channel-artifacts/paymentgatewayschannel.block
peer channel create -o orderer.pesachain.com:7050 -c complianceentitieschannel -f ./channel-artifacts/complianceentitieschannel.tx --outputBlock ./channel-artifacts/complianceentitieschannel.block

