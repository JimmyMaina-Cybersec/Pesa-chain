#!/bin/bash

# Stop the network first
./scripts/stop-network.sh

# Remove crypto material
rm -rf crypto-config/*

# Remove channel artifacts
rm -rf channel-artifacts/*

# Remove chaincode packages
rm -rf packages/*

# Clean Docker resources
docker system prune -f

echo "Network cleaned successfully"