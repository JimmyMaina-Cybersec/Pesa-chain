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
echo -e "\nUpdating /etc/hosts..."
sudo sed -i '/pesachain.local/d' /etc/hosts
sudo sed -i '/orderer.local/d' /etc/hosts
echo "$MINIKUBE_IP   pesachain.local" | sudo tee -a /etc/hosts
echo "$MINIKUBE_IP   orderer.local" | sudo tee -a /etc/hosts

echo -e "\nMinikube IP ($MINIKUBE_IP) has been added to /etc/hosts with the domains 'pesachain.local' and 'orderer.local'"
