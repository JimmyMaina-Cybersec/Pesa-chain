#!/usr/bin/env bash

mkdir -p crypto-config-ca/peerOrganizations/pesachain.com/peers

createMSPPeer0() {
  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@ca.pesachain.com:7054 --caname ca.pesachain.com -M ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/msp --csr.hosts peer0.pesachain.com --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem

  sleep 5
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@ca.pesachain.com:7054 --caname ca.pesachain.com -M ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls --enrollment.profile tls --csr.hosts peer0.pesachain.com --csr.hosts pesachain --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem
  sleep 5
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/tlsca/tlsca.pesachain.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer0.pesachain.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/ca/ca.pesachain.com-cert.pem

  # ------------------------------------------------------------------------------------------------
}
createMSPPeer1() {
  # Peer1

  mkdir -p crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com

  echo
  echo "## Generate the peer1 msp"
  echo
  fabric-ca-client enroll -u https://peer1:peer1pw@ca.pesachain.com:7054 --caname ca.pesachain.com -M ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/msp --csr.hosts peer1.pesachain.com --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem

  sleep 5
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer1:peer1pw@ca.pesachain.com:7054 --caname ca.pesachain.com -M ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/tls --enrollment.profile tls --csr.hosts peer1.pesachain.com --csr.hosts pesachain --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem
  sleep 5
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/peers/peer1.pesachain.com/tls/server.key

  # --------------------------------------------------------------------------------------------------

}
generateUserMSP() {
  mkdir -p crypto-config-ca/peerOrganizations/pesachain.com/users
  mkdir -p crypto-config-ca/peerOrganizations/pesachain.com/users/User1@pesachain.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@ca.pesachain.com:7054 --caname ca.pesachain.com -M ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/users/User1@pesachain.com/msp --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem

	cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/users/User1@pesachain.com/msp

}
generateAdminMSP() {
  echo
  echo "## Generate the pesachain admin msp"
  echo
  fabric-ca-client enroll -u https://pesachainadmin:pesachainadminpw@ca.pesachain.com:7054 --caname ca.pesachain.com -M ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/users/Admin@pesachain.com/msp --tls.certfiles ${PWD}/fabric-ca/pesachain/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/pesachain.com/users/Admin@pesachain.com/msp/config.yaml

}
createMSPPeer0
createMSPPeer1
generateUserMSP
generateAdminMSP
sleep 10
docker-compose -f docker-compose-peer.yaml up -d
sleep 10
docker ps -a
