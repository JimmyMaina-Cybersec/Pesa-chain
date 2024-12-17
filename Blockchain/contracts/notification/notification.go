package notification

import (
    "encoding/json"
    "fmt"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type NotificationContract struct {
    contractapi.Contract
}

type Notification struct {
    ID          string `json:"id"`
    Type        string `json:"type"`
    EntityID    string `json:"entityId"`
    Message     string `json:"message"`
    Status      string `json:"status"`
    CreatedAt   int64  `json:"createdAt"`
    DeliveredAt int64  `json:"deliveredAt"`
}

func (nc *NotificationContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
    return nil
}

func (nc *NotificationContract) CreateNotification(ctx contractapi.TransactionContextInterface, 
    id string, 
    notificationType string, 
    entityID string, 
    message string) error {

    exists, err := nc.NotificationExists(ctx, id)
    if err != nil {
        return fmt.Errorf("failed to check notification existence: %v", err)
    }
    if exists {
        return fmt.Errorf("notification %s already exists", id)
    }

    notification := Notification{
        ID:          id,
        Type:        notificationType,
        EntityID:    entityID,
        Message:     message,
        Status:      "PENDING",
        CreatedAt:   ctx.GetStub().GetTxTimestamp().Seconds,
        DeliveredAt: 0,
    }

    notificationJSON, err := json.Marshal(notification)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState(id, notificationJSON)
}

func (nc *NotificationContract) MarkAsDelivered(ctx contractapi.TransactionContextInterface, id string) error {
    notification, err := nc.GetNotification(ctx, id)
    if err != nil {
        return err
    }

    notification.Status = "DELIVERED"
    notification.DeliveredAt = ctx.GetStub().GetTxTimestamp().Seconds

    notificationJSON, err := json.Marshal(notification)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState(id, notificationJSON)
}

func (nc *NotificationContract) GetNotification(ctx contractapi.TransactionContextInterface, id string) (*Notification, error) {
    notificationJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return nil, fmt.Errorf("failed to read notification: %v", err)
    }
    if notificationJSON == nil {
        return nil, fmt.Errorf("notification %s does not exist", id)
    }

    var notification Notification
    err = json.Unmarshal(notificationJSON, &notification)
    if err != nil {
        return nil, err
    }

    return &notification, nil
}

func (nc *NotificationContract) NotificationExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
    notificationJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return false, fmt.Errorf("failed to read from world state: %v", err)
    }

    return notificationJSON != nil, nil
}