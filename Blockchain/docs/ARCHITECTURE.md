# Pesachain Network Architecture

## Overview
Pesachain is a Hyperledger Fabric network designed for secure cross-border payments and settlements.

## Network Components

### Organizations
- Pesachain (Remittance Provider)
- Bank1
- Bank2

### Nodes
- 2 peers per organization
- 3-node Raft ordering service
- Certificate Authority per organization

### Channels
1. bank-consortium
   - Members: Bank1, Bank2
   - Purpose: Bank-to-bank transactions

2. payment-gateway
   - Members: Pesachain, Bank1, Bank2
   - Purpose: Cross-border payments

## Smart Contracts
1. Remittance Contract
   - Payment processing
   - Currency conversion
   - Transaction validation

2. Settlement Contract
   - Fund transfers
   - Escrow management
   - Settlement finalization

3. Notification Contract
   - Event notifications
   - Status updates
   - Transaction confirmations

## Security
- TLS enabled for all communications
- MSP-based identity management
- Organization-specific CAs
- Role-based access control

## Monitoring
- Prometheus metrics collection
- Grafana dashboards
- ELK stack for log aggregation

## High Availability
- Multiple peers per organization
- Raft consensus for ordering service
- Regular state database backups