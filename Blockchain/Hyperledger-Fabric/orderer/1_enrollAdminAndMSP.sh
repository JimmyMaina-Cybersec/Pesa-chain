#!/usr/bin/env bash

setupOrdererCA() {

  echo "Setting Orderer CA"
  docker-compose -f ca-orderer.yaml up -d
  sleep 10
  mkdir -p crypto-config-ca/ordererOrganizations/orderer.com
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/ordererOrganizations/orderer.com
}
enrollCAAdmin() {
  echo
  echo "Enroll the CA admin"
  echo

  fabric-ca-client enroll -u https://admin:adminpw@ca.orderer.com:9054 --caname ca.orderer.com --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
  sleep 2
}
nodeOrgnisationUnit() {
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/orderer-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/orderer-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/orderer-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/orderer-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/msp/config.yaml
  sleep 2
}
registerUsers() {
  echo
  echo "Register orderer"
  echo

  fabric-ca-client register --caname ca.orderer.com --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
  sleep 2

  echo
  echo "Register orderer2"
  echo

  fabric-ca-client register --caname ca.orderer.com --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem

  sleep 2
  echo
  echo "Register orderer3"
  echo

  fabric-ca-client register --caname ca.orderer.com --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem

  sleep 2
  echo
  echo "Register the orderer admin"
  echo

  fabric-ca-client register --caname ca.orderer.com --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
  sleep 2

  mkdir -p crypto-config-ca/ordererOrganizations/orderer.com/orderers

}
orderer1MSP() {

  mkdir -p crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com

  echo
  echo "## Generate the orderer msp"
  echo

  fabric-ca-client enroll -u https://orderer:ordererpw@ca.orderer.com:9054 --caname ca.orderer.com -M ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/msp --csr.hosts orderer.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem

  sleep 2

  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo

  fabric-ca-client enroll -u https://orderer:ordererpw@ca.orderer.com:9054 --caname ca.orderer.com -M ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls --enrollment.profile tls --csr.hosts orderer.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem

  sleep 2

  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/msp/tlscacerts/tlsca.orderer.com-cert.pem

}
orderer2MSP() {
  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com

  echo
  echo "## Generate the orderer msp"
  echo

  fabric-ca-client enroll -u https://orderer2:ordererpw@ca.orderer.com:9054 --caname ca.orderer.com -M ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/msp --csr.hosts orderer2.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
  sleep 2

  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo

  fabric-ca-client enroll -u https://orderer2:ordererpw@ca.orderer.com:9054 --caname ca.orderer.com -M ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/tls --enrollment.profile tls --csr.hosts orderer2.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem

  sleep 2
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer2.com/msp/tlscacerts/tlsca.orderer2.com-cert.pem

  # mkdir ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/crypto-config-ca/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

}
orderer3MSP() {
  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com

  echo
  echo "## Generate the orderer msp"
  echo

  fabric-ca-client enroll -u https://orderer3:ordererpw@ca.orderer.com:9054 --caname ca.orderer.com -M ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/msp --csr.hosts orderer3.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem

  sleep 2
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo

  fabric-ca-client enroll -u https://orderer3:ordererpw@ca.orderer.com:9054 --caname ca.orderer.com -M ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/tls --enrollment.profile tls --csr.hosts orderer3.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem

  sleep 2
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/orderers/orderer3.com/msp/tlscacerts/tlsca.orderer3.com-cert.pem

}
adminMSP() {
  mkdir -p crypto-config-ca/ordererOrganizations/orderer.com/users
  mkdir -p crypto-config-ca/ordererOrganizations/orderer.com/users/Admin@ca.orderer.com

  echo
  echo "## Generate the admin msp"
  echo

  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@ca.orderer.com:9054 --caname ca.orderer.com -M ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/users/Admin@ca.orderer.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem

  sleep 2
  cp ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/orderer.com/users/Admin@ca.orderer.com/msp/config.yaml

}
setupOrdererCA
enrollCAAdmin
nodeOrgnisationUnit
registerUsers
orderer1MSP
orderer2MSP
orderer3MSP
adminMSP
