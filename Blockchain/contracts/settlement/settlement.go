package settlement

import (
    "encoding/json"
    "fmt"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SettlementContract struct {
    contractapi.Contract
}

type Settlement struct {
    ID            string  `json:"id"`
    RemittanceID  string  `json:"remittanceId"`
    Amount        float64 `json:"amount"`
    Status        string  `json:"status"`
    EscrowID      string  `json:"escrowId"`
    SettledAt     int64   `json:"settledAt"`
}

type Escrow struct {
    ID        string  `json:"id"`
    Amount    float64 `json:"amount"`
    Status    string  `json:"status"`
    CreatedAt int64   `json:"createdAt"`
}

func (sc *SettlementContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
    return nil
}

func (sc *SettlementContract) CreateSettlement(ctx contractapi.TransactionContextInterface, 
    id string, 
    remittanceID string, 
    amount float64) error {

    exists, err := sc.SettlementExists(ctx, id)
    if err != nil {
        return fmt.Errorf("failed to check settlement existence: %v", err)
    }
    if exists {
        return fmt.Errorf("settlement %s already exists", id)
    }

    escrowID, err := sc.createEscrow(ctx, amount)
    if err != nil {
        return err
    }

    settlement := Settlement{
        ID:           id,
        RemittanceID: remittanceID,
        Amount:       amount,
        Status:       "PENDING",
        EscrowID:     escrowID,
        SettledAt:    ctx.GetStub().GetTxTimestamp().Seconds,
    }

    settlementJSON, err := json.Marshal(settlement)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState(id, settlementJSON)
}

func (sc *SettlementContract) createEscrow(ctx contractapi.TransactionContextInterface, amount float64) (string, error) {
    escrowID := fmt.Sprintf("ESCROW_%d", ctx.GetStub().GetTxTimestamp().Seconds)
    
    escrow := Escrow{
        ID:        escrowID,
        Amount:    amount,
        Status:    "ACTIVE",
        CreatedAt: ctx.GetStub().GetTxTimestamp().Seconds,
    }

    escrowJSON, err := json.Marshal(escrow)
    if err != nil {
        return "", err
    }

    err = ctx.GetStub().PutState(escrowID, escrowJSON)
    if err != nil {
        return "", err
    }

    return escrowID, nil
}

func (sc *SettlementContract) SettlementExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
    settlementJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return false, fmt.Errorf("failed to read from world state: %v", err)
    }

    return settlementJSON != nil, nil
}