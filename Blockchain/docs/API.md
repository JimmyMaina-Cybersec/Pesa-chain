# Pesachain Network API Documentation

## Chaincode APIs

### Remittance Contract

#### CreateRemittance
```go
CreateRemittance(ctx, id, senderBank, receiverBank, amount, sourceCurrency, targetCurrency)
```
- Parameters:
  - id: Unique remittance identifier
  - senderBank: Source bank identifier
  - receiverBank: Destination bank identifier
  - amount: Transfer amount
  - sourceCurrency: Source currency code
  - targetCurrency: Target currency code

#### GetRemittance
```go
GetRemittance(ctx, id)
```
- Parameters:
  - id: Remittance identifier

### Settlement Contract

#### CreateSettlement
```go
CreateSettlement(ctx, id, remittanceID, amount)
```
- Parameters:
  - id: Settlement identifier
  - remittanceID: Associated remittance
  - amount: Settlement amount

### Notification Contract

#### CreateNotification
```go
CreateNotification(ctx, id, type, entityID, message)
```
- Parameters:
  - id: Notification identifier
  - type: Notification type
  - entityID: Related entity
  - message: Notification content

## Event Types

1. RemittanceCreated
2. RemittanceCompleted
3. SettlementInitiated
4. SettlementCompleted
5. NotificationSent

## Error Codes

- 1000: Invalid input parameters
- 1001: Insufficient funds
- 1002: Entity not found
- 1003: Unauthorized access
- 1004: Network error