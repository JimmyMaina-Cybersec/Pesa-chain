package main

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/pkg/cid"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// PaymentTransaction defines the structure for a payment transaction.
type PaymentTransaction struct {
	TransactionID   string  `json:"transactionID"`
	TransactionType string  `json:"transactionType"` // e.g., "EFT", "ACH", "Wire", "RTP", "CreditCard", etc.
	Sender          string  `json:"sender"`
	Receiver        string  `json:"receiver"`
	Amount          float64 `json:"amount"`
	Currency        string  `json:"currency"`
	Timestamp       string  `json:"timestamp"`
	// Additional fields can be added as needed.
}

// SmartContract provides functions for managing PaymentTransactions.
type SmartContract struct {
	contractapi.Contract
}

// sensitiveTransactionTypes holds the list of transaction types considered sensitive.
var sensitiveTransactionTypes = []string{"CreditCard", "MobileWallet"}

// IsSensitiveType returns true if the provided transactionType is in the sensitive list.
func IsSensitiveType(transactionType string) bool {
	for _, t := range sensitiveTransactionTypes {
		if strings.EqualFold(t, transactionType) {
			return true
		}
	}
	return false
}

// CheckIfPartyExists verifies that the invoker belongs to one of the allowed MSPs.
// In this example, we only allow parties from "PesachainMSP" and "Org2MSP".
func (s *SmartContract) CheckIfPartyExists(ctx contractapi.TransactionContextInterface) error {
	allowedMSPs := []string{"PesachainMSP", "Org2MSP"}
	mspID, err := cid.GetMSPID(ctx.GetStub())
	if err != nil {
		return fmt.Errorf("failed to get MSP ID: %v", err)
	}
	for _, allowed := range allowedMSPs {
		if mspID == allowed {
			return nil
		}
	}
	return fmt.Errorf("invoker MSP '%s' is not authorized to initiate transactions", mspID)
}

// CheckClientAttribute verifies that the client holds a specific attribute value.
// For example, you could require that the client's "role" attribute equals "finance".
func (s *SmartContract) CheckClientAttribute(ctx contractapi.TransactionContextInterface, attrName, expectedValue string) error {
	val, found, err := cid.GetAttributeValue(ctx.GetStub(), attrName)
	if err != nil {
		return fmt.Errorf("failed to get attribute %s: %v", attrName, err)
	}
	if !found {
		return fmt.Errorf("attribute %s not found in client's certificate", attrName)
	}
	if val != expectedValue {
		return fmt.Errorf("client does not have required attribute %s=%s", attrName, expectedValue)
	}
	return nil
}

// InitLedger initializes the ledger with some sample public transactions.
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	transactions := []PaymentTransaction{
		{
			TransactionID:   "TXN1",
			TransactionType: "EFT",
			Sender:          "Alice",
			Receiver:        "Bob",
			Amount:          100.0,
			Currency:        "USD",
			Timestamp:       time.Now().Format(time.RFC3339),
		},
	}

	for _, txn := range transactions {
		txnJSON, err := json.Marshal(txn)
		if err != nil {
			return fmt.Errorf("failed to marshal transaction: %v", err)
		}

		err = ctx.GetStub().PutState(txn.TransactionID, txnJSON)
		if err != nil {
			return fmt.Errorf("failed to put state for transaction %s: %v", txn.TransactionID, err)
		}
		// Emit an event for ledger initialization.
		err = ctx.GetStub().SetEvent("TransactionInit", txnJSON)
		if err != nil {
			return fmt.Errorf("failed to set event for transaction %s: %v", txn.TransactionID, err)
		}
	}

	return nil
}

// InitSensitiveData initializes the ledger with a sample sensitive transaction.
func (s *SmartContract) InitSensitiveData(ctx contractapi.TransactionContextInterface) error {
	txn := PaymentTransaction{
		TransactionID:   "TXN2",
		TransactionType: "CreditCard",
		Sender:          "Carol",
		Receiver:        "Dave",
		Amount:          250.0,
		Currency:        "USD",
		Timestamp:       time.Now().Format(time.RFC3339),
	}

	txnJSON, err := json.Marshal(txn)
	if err != nil {
		return fmt.Errorf("failed to marshal sensitive transaction: %v", err)
	}

	err = ctx.GetStub().PutPrivateData("sensitiveTransactions", txn.TransactionID, txnJSON)
	if err != nil {
		return fmt.Errorf("failed to put private data for transaction %s: %v", txn.TransactionID, err)
	}

	err = ctx.GetStub().SetEvent("SensitiveTransactionInit", txnJSON)
	if err != nil {
		return fmt.Errorf("failed to set event for sensitive transaction %s: %v", txn.TransactionID, err)
	}

	return nil
}

// CreateTransaction creates a new PaymentTransaction.
// It first checks that the invoker is from an authorized organization and, optionally, has the required attributes.
// It also validates the inputs before storing the transaction.
func (s *SmartContract) CreateTransaction(ctx contractapi.TransactionContextInterface, transactionID string, transactionType string, sender string, receiver string, amount float64, currency string) error {
	// Verify that the invoker is a registered party
	if err := s.CheckIfPartyExists(ctx); err != nil {
		return fmt.Errorf("authorization failed: %v", err)
	}

	// (Optional) Verify a specific attribute; for example, require that the client has role "finance"
	// Uncomment the following block if you require this check:
	/*
		if err := s.CheckClientAttribute(ctx, "role", "finance"); err != nil {
			return fmt.Errorf("client attribute check failed: %v", err)
		}
	*/

	// Input validation
	if strings.TrimSpace(transactionID) == "" {
		return fmt.Errorf("transactionID cannot be empty")
	}
	if amount <= 0 {
		return fmt.Errorf("transaction amount must be greater than zero")
	}
	if strings.TrimSpace(sender) == "" || strings.TrimSpace(receiver) == "" {
		return fmt.Errorf("sender and receiver must be non-empty")
	}

	txn := PaymentTransaction{
		TransactionID:   transactionID,
		TransactionType: transactionType,
		Sender:          sender,
		Receiver:        receiver,
		Amount:          amount,
		Currency:        currency,
		Timestamp:       time.Now().Format(time.RFC3339),
	}

	txnJSON, err := json.Marshal(txn)
	if err != nil {
		return fmt.Errorf("failed to marshal transaction: %v", err)
	}

	// Store the transaction in the appropriate ledger store based on sensitivity.
	if IsSensitiveType(transactionType) {
		err = ctx.GetStub().PutPrivateData("sensitiveTransactions", transactionID, txnJSON)
		if err != nil {
			return fmt.Errorf("failed to put private data for transaction %s: %v", transactionID, err)
		}
	} else {
		err = ctx.GetStub().PutState(transactionID, txnJSON)
		if err != nil {
			return fmt.Errorf("failed to put state for transaction %s: %v", transactionID, err)
		}
	}

	// Emit an event for transaction creation
	err = ctx.GetStub().SetEvent("TransactionCreated", txnJSON)
	if err != nil {
		return fmt.Errorf("failed to set event for transaction %s: %v", transactionID, err)
	}

	return nil
}

// QueryTransaction retrieves a transaction by its TransactionID.
func (s *SmartContract) QueryTransaction(ctx contractapi.TransactionContextInterface, transactionID string, transactionType string) (*PaymentTransaction, error) {
	var txnJSON []byte
	var err error

	if IsSensitiveType(transactionType) {
		txnJSON, err = ctx.GetStub().GetPrivateData("sensitiveTransactions", transactionID)
		if err != nil {
			return nil, fmt.Errorf("failed to get private data for transaction %s: %v", transactionID, err)
		}
		if txnJSON == nil {
			return nil, fmt.Errorf("transaction %s does not exist in private data", transactionID)
		}
	} else {
		txnJSON, err = ctx.GetStub().GetState(transactionID)
		if err != nil {
			return nil, fmt.Errorf("failed to get state for transaction %s: %v", transactionID, err)
		}
		if txnJSON == nil {
			return nil, fmt.Errorf("transaction %s does not exist", transactionID)
		}
	}

	var txn PaymentTransaction
	err = json.Unmarshal(txnJSON, &txn)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal transaction JSON: %v", err)
	}

	return &txn, nil
}

// QueryAllTransactions returns all transactions stored in the public ledger.
// (Note: Private transactions are not returned here.)
func (s *SmartContract) QueryAllTransactions(ctx contractapi.TransactionContextInterface) ([]*PaymentTransaction, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, fmt.Errorf("failed to get state by range: %v", err)
	}
	defer resultsIterator.Close()

	var transactions []*PaymentTransaction
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var txn PaymentTransaction
		err = json.Unmarshal(queryResponse.Value, &txn)
		if err != nil {
			return nil, err
		}
		transactions = append(transactions, &txn)
	}

	return transactions, nil
}

// UpdateTransaction updates an existing transaction in the public ledger.
func (s *SmartContract) UpdateTransaction(ctx contractapi.TransactionContextInterface, transactionID string, newAmount float64) error {
	// Check if the invoker is authorized (MSP check)
	if err := s.CheckIfPartyExists(ctx); err != nil {
		return fmt.Errorf("authorization failed: %v", err)
	}

	txnJSON, err := ctx.GetStub().GetState(transactionID)
	if err != nil {
		return fmt.Errorf("failed to get state for transaction %s: %v", transactionID, err)
	}
	if txnJSON == nil {
		return fmt.Errorf("transaction %s does not exist", transactionID)
	}

	var txn PaymentTransaction
	err = json.Unmarshal(txnJSON, &txn)
	if err != nil {
		return fmt.Errorf("failed to unmarshal transaction JSON: %v", err)
	}

	// Update transaction details
	txn.Amount = newAmount
	txn.Timestamp = time.Now().Format(time.RFC3339)

	updatedTxnJSON, err := json.Marshal(txn)
	if err != nil {
		return fmt.Errorf("failed to marshal updated transaction: %v", err)
	}

	err = ctx.GetStub().PutState(transactionID, updatedTxnJSON)
	if err != nil {
		return fmt.Errorf("failed to update state for transaction %s: %v", transactionID, err)
	}

	// Emit update event
	err = ctx.GetStub().SetEvent("TransactionUpdated", updatedTxnJSON)
	if err != nil {
		return fmt.Errorf("failed to set event for updated transaction %s: %v", transactionID, err)
	}

	return nil
}

// DeleteTransaction removes a transaction from the public ledger.
func (s *SmartContract) DeleteTransaction(ctx contractapi.TransactionContextInterface, transactionID string) error {
	err := ctx.GetStub().DelState(transactionID)
	if err != nil {
		return fmt.Errorf("failed to delete transaction %s: %v", transactionID, err)
	}

	// Emit deletion event
	err = ctx.GetStub().SetEvent("TransactionDeleted", []byte(transactionID))
	if err != nil {
		return fmt.Errorf("failed to set deletion event for transaction %s: %v", transactionID, err)
	}

	return nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating PaymentsChaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting PaymentsChaincode: %s", err.Error())
	}
}
