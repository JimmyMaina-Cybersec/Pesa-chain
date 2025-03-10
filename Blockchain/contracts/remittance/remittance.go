package remittance

import (
    "encoding/json"
    "fmt"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
    "github.com/hyperledger/fabric-chaincode-go/shim"
)

type RemittanceContract struct {
    contractapi.Contract
}

type Remittance struct {
    ID              string  `json:"id"`
    SenderBank      string  `json:"senderBank"`
    ReceiverBank    string  `json:"receiverBank"`
    Amount          float64 `json:"amount"`
    SourceCurrency  string  `json:"sourceCurrency"`
    TargetCurrency  string  `json:"targetCurrency"`
    ExchangeRate    float64 `json:"exchangeRate"`
    Status          string  `json:"status"`
    Timestamp       int64   `json:"timestamp"`
}

func (rc *RemittanceContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
    return nil
}

func (rc *RemittanceContract) CreateRemittance(ctx contractapi.TransactionContextInterface, 
    id string, 
    senderBank string, 
    receiverBank string, 
    amount float64, 
    sourceCurrency string, 
    targetCurrency string) error {

    exists, err := rc.RemittanceExists(ctx, id)
    if err != nil {
        return fmt.Errorf("failed to check remittance existence: %v", err)
    }
    if exists {
        return fmt.Errorf("remittance %s already exists", id)
    }

    exchangeRate, err := rc.getExchangeRate(sourceCurrency, targetCurrency)
    if err != nil {
        return err
    }

    remittance := Remittance{
        ID:             id,
        SenderBank:     senderBank,
        ReceiverBank:   receiverBank,
        Amount:         amount,
        SourceCurrency: sourceCurrency,
        TargetCurrency: targetCurrency,
        ExchangeRate:   exchangeRate,
        Status:         "PENDING",
        Timestamp:      ctx.GetStub().GetTxTimestamp().Seconds,
    }

    remittanceJSON, err := json.Marshal(remittance)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState(id, remittanceJSON)
}

func (rc *RemittanceContract) GetRemittance(ctx contractapi.TransactionContextInterface, id string) (*Remittance, error) {
    remittanceJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return nil, fmt.Errorf("failed to read remittance: %v", err)
    }
    if remittanceJSON == nil {
        return nil, fmt.Errorf("remittance %s does not exist", id)
    }

    var remittance Remittance
    err = json.Unmarshal(remittanceJSON, &remittance)
    if err != nil {
        return nil, err
    }

    return &remittance, nil
}

func (rc *RemittanceContract) RemittanceExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
    remittanceJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return false, fmt.Errorf("failed to read from world state: %v", err)
    }

    return remittanceJSON != nil, nil
}

func (rc *RemittanceContract) getExchangeRate(sourceCurrency, targetCurrency string) (float64, error) {
    // In production, this would integrate with an external exchange rate service
    // For demonstration, returning a mock rate
    return 1.2, nil
}