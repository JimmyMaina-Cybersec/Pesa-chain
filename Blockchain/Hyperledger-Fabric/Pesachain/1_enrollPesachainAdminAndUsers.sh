#!/usr/bin/env bash

setupPesachainCA() {

  echo "Setting Pesachain CA"
  docker-compose -f ca-pesachain.yaml up -d

  sleep 10
  mkdir -p crypto-config-ca/peerOrganizations/pesachain.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/
}

#here we are generating crypto material insted of cryptogen we are using CA
createcertificatesForPesachain() {
  echo
  echo "Enroll the CA admin"
  echo

  fabric-ca-client enroll -u https://admin:adminpw@ca.pesachain.com:7054 --caname ca.pesachain.com --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem
}
#Orgnisation units will be useful in future
nodeOrgnisationUnit() {
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/pesachain-7054-ca-pesachain.com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/pesachain-7054-ca-pesachain.com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/pesachain-7054-ca-pesachain.com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/pesachain-7054-ca-pesachain.com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/msp/config.yaml

}
registerUsers() {
  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.pesachain.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem

  echo
  echo "Register peer1"
  echo
  fabric-ca-client register --caname ca.pesachain.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.pesachain.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem

  echo
  echo "Register the pesachain admin"
  echo
  fabric-ca-client register --caname ca.pesachain.com --id.name pesachainadmin --id.secret pesachainadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem
}
setupPesachainCA
createcertificatesForPesachain
sleep 2
nodeOrgnisationUnit
sleep 2
registerUsers
