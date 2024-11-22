#!/bin/bash

# Start Minikube if it's not running
minikube status > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Starting Minikube..."
    minikube start
fi

# Get the Minikube IP
MINIKUBE_IP=$(minikube ip)

# Update /etc/hosts for peer0 and orderer0
sudo sed -i '/pesachain.local/d' /etc/hosts
sudo sed -i '/orderer.local/d' /etc/hosts
echo "$MINIKUBE_IP   peer0.local" | sudo tee -a /etc/hosts
echo "$MINIKUBE_IP   orderer0.local" | sudo tee -a /etc/hosts

echo "Minikube IP ($MINIKUBE_IP) has been added to /etc/hosts with the domains 'peer0.local' and 'orderer0.local'"
