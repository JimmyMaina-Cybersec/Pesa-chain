package utils

import (
    "encoding/json"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

const (
    RemittanceCreated    = "RemittanceCreated"
    RemittanceCompleted  = "RemittanceCompleted"
    SettlementInitiated  = "SettlementInitiated"
    SettlementCompleted  = "SettlementCompleted"
    NotificationSent     = "NotificationSent"
)

type Event struct {
    Type      string      `json:"type"`
    EntityID  string      `json:"entityId"`
    Data      interface{} `json:"data"`
    Timestamp int64       `json:"timestamp"`
}

func EmitEvent(ctx contractapi.TransactionContextInterface, eventType string, entityID string, data interface{}) error {
    event := Event{
        Type:      eventType,
        EntityID:  entityID,
        Data:      data,
        Timestamp: ctx.GetStub().GetTxTimestamp().Seconds,
    }

    eventJSON, err := json.Marshal(event)
    if err != nil {
        return err
    }

    return ctx.GetStub().SetEvent(eventType, eventJSON)
}