package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	pb "github.com/hyperledger/fabric-protos-go/peer"

	"github.com/JimmyMaina-Cybersec/Pesa-chain/Blockchain/Hyperledger-Fabric/chaincodes/golang/common/identity"
	"github.com/JimmyMaina-Cybersec/Pesa-chain/Blockchain/Hyperledger-Fabric/chaincodes/golang/common/logging"
)

const (
	// ChaincodeMappingKey is the ledger key for dynamic chaincode configuration.
	ChaincodeMappingKey = "CHAINCODE_MAPPING"
	AuthorizedMSPsKey = "AUTHORIZED_MSPS"
)

// PaymentsControllerCC is the main chaincode struct.
type PaymentsControllerCC struct{}

// PaymentRequest represents the payment request received.
type PaymentRequest struct {
	TransactionType string            `json:"transactionType"`
	Payload         map[string]string `json:"payload"`
}

// ErrorResponse provides a standardized JSON error structure.
type ErrorResponse struct {
	ErrorCode string `json:"errorCode"`
	Message   string `json:"message"`
}

// Init initializes the chaincode, sets default chaincode mappings and authorized MSPs if they are absent.
func (cc *PaymentsControllerCC) Init(stub shim.ChaincodeStubInterface) pb.Response {
	// Set default transaction-type to chaincode mapping.
	defaultMapping := map[string]string{
		"bankTransfers":     "bankTransfersCC",
		"cardPayments":      "cardPaymentsCC",
		"digitalWallets":    "digitalWalletsCC",
		"p2pTransfers":      "p2pTransfersCC",
		"remittances":       "remittancesCC",
		"merchantServices":  "merchantServicesCC",
		"atmTransactions":   "atmTransactionsCC",
	}
	mappingBytes, _ := json.Marshal(defaultMapping)
	existing, _ := stub.GetState(ChaincodeMappingKey)
	if len(existing) == 0 {
		stub.PutState(ChaincodeMappingKey, mappingBytes)
	}

	// Store authorized MSPs on-chain
	authorizedMSPs := []string{"Org2MSP", "PesachainMSP"}
	mspBytes, _ := json.Marshal(authorizedMSPs)
	stub.PutState(AuthorizedMSPsKey, mspBytes)

	return shim.Success(nil)
}

// Invoke routes incoming transactions.
func (cc *PaymentsControllerCC) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	switch function {
	case "dispatchPayment":
		return cc.dispatchPayment(stub, args)
	default:
		return cc.errorResponse("INVALID_FUNCTION", "Invalid function name")
	}
}

// dispatchPayment validates the request, performs identity checks, and routes it to the target chaincode.
func (cc *PaymentsControllerCC) dispatchPayment(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	txID := stub.GetTxID()
	logging.LogTxStart(txID, "dispatchPayment")

	// Parse and validate payment request
	if len(args) != 1 {
		return cc.errorResponse("INVALID_ARGUMENTS", "Expecting one JSON argument for PaymentRequest")
	}
	var req PaymentRequest
	if err := json.Unmarshal([]byte(args[0]), &req); err != nil {
		return cc.errorResponse("INVALID_JSON", "Unable to parse PaymentRequest JSON")
	}
	if req.TransactionType == "" || req.Payload == nil {
		return cc.errorResponse("MISSING_FIELDS", "Missing required fields in PaymentRequest")
	}

	// Get MSP ID
	mspID, err := identity.GetMSPID(stub)
	if err != nil {
		return cc.errorResponse("AUTH_FAILURE", fmt.Sprintf("Failed to get MSP ID: %s", err))
	}

	// Get allowed MSPs from ledger
	authorizedBytes, err := stub.GetState(AuthorizedMSPsKey)
	if err != nil || len(authorizedBytes) == 0 {
		return cc.errorResponse("AUTH_CONFIG_MISSING", "Authorized MSP list missing or unreadable")
	}
	var allowedMSPs []string
	if err := json.Unmarshal(authorizedBytes, &allowedMSPs); err != nil {
		return cc.errorResponse("AUTH_PARSE_ERROR", "Failed to parse authorized MSPs")
	}
	found := false
	for _, msp := range allowedMSPs {
		if msp == mspID {
			found = true
			break
		}
	}
	if !found {
		return cc.errorResponse("UNAUTHORIZED_MSP", fmt.Sprintf("MSP %s is not authorized", mspID))
	}

	// Optional: Check hf.Type attribute == "client"
	userType, found, _ := identity.GetAttributeValue(stub, "hf.Type")
	if !found || userType != "client" {
		return cc.errorResponse("INVALID_TYPE", "Only client identities can dispatch payments")
	}

	// Resolve target chaincode.
	targetCC, err := cc.getTargetChaincode(stub, req.TransactionType)
	if err != nil {
		return cc.errorResponse("UNSUPPORTED_TYPE", err.Error())
	}

	// Prepare payload for target chaincode.
	payloadBytes, err := json.Marshal(req.Payload)
	if err != nil {
		return cc.errorResponse("PAYLOAD_ERROR", "Failed to marshal payload")
	}

	// Dispatch request to the target chaincode.
	response := stub.InvokeChaincode(targetCC, [][]byte{[]byte("processTransaction"), payloadBytes}, "")
	if response.Status != shim.OK {
		return cc.errorResponse("CHAINCODE_INVOKE_FAIL", fmt.Sprintf("Target chaincode error: %s", response.Message))
	}

	logging.LogTxEnd(txID, "dispatchPayment")
	return shim.Success(response.Payload)
}

// getTargetChaincode retrieves the target chaincode for a given transaction type from ledger state.
// Falls back to a hard-coded default mapping.
func (cc *PaymentsControllerCC) getTargetChaincode(stub shim.ChaincodeStubInterface, txType string) (string, error) {
	mappingBytes, err := stub.GetState(ChaincodeMappingKey)
	if err != nil || len(mappingBytes) == 0 {
		return cc.resolveTargetChaincodeFallback(txType), nil
	}

	var mapping map[string]string
	if err := json.Unmarshal(mappingBytes, &mapping); err != nil {
		return "", fmt.Errorf("failed to parse chaincode mapping: %s", err)
	}

	target, exists := mapping[txType]
	if !exists || target == "" {
		return "", fmt.Errorf("unsupported transaction type: %s", txType)
	}
	return target, nil
}

// resolveTargetChaincodeFallback returns a default chaincode mapping for a given transaction type.
func (cc *PaymentsControllerCC) resolveTargetChaincodeFallback(txType string) string {
	switch txType {
	case "bankTransfers":
		return "bankTransfersCC"
	case "cardPayments":
		return "cardPaymentsCC"
	case "digitalWallets":
		return "digitalWalletsCC"
	case "p2pTransfers":
		return "p2pTransfersCC"
	case "remittances":
		return "remittancesCC"
	case "merchantServices":
		return "merchantServicesCC"
	case "atmTransactions":
		return "atmTransactionsCC"
	default:
		return ""
	}
}

// errorResponse constructs and returns a standardized JSON error response.
func (cc *PaymentsControllerCC) errorResponse(code, message string) pb.Response {
	errResp := ErrorResponse{
		ErrorCode: code,
		Message:   message,
	}
	errBytes, _ := json.Marshal(errResp)
	return shim.Error(string(errBytes))
}

func main() {
	err := shim.Start(new(PaymentsControllerCC))
	if err != nil {
		fmt.Printf("Error starting PaymentsControllerCC: %s\n", err)
	}
}
