package identity

import (
	"fmt"
	"strings"

	"github.com/hyperledger/fabric-chaincode-go/pkg/cid"
	"github.com/hyperledger/fabric-chaincode-go/shim"
)

// GetMSPID returns the MSP ID of the invoking client.
func GetMSPID(stub shim.ChaincodeStubInterface) (string, error) {
    mspid, err := cid.GetMSPID(stub)
    if err != nil {
        return "", fmt.Errorf("failed to get MSP ID: %w", err)
    }
    return mspid, nil
}

// GetUserID returns the unique ID of the invoking client.
func GetUserID(stub shim.ChaincodeStubInterface) (string, error) {
    id, err := cid.GetID(stub)
    if err != nil {
        return "", fmt.Errorf("failed to get client ID: %w", err)
    }
    return id, nil
}

// IsUserInOrg returns true if the invoking user belongs to the specified MSP ID.
func IsUserInOrg(stub shim.ChaincodeStubInterface, expectedMSPID string) (bool, error) {
    userMSPID, err := GetMSPID(stub)
    if err != nil {
        return false, err
    }
    return strings.EqualFold(userMSPID, expectedMSPID), nil
}

// HasAttribute checks if the user's identity has a specific attribute.
func HasAttribute(stub shim.ChaincodeStubInterface, attrName string) (bool, error) {
    _, found, err := cid.GetAttributeValue(stub, attrName)
    if err != nil {
        return false, err
    }
    return found, nil
}

// GetAttributeValue returns the value of a specific attribute in the user's identity.
func GetAttributeValue(stub shim.ChaincodeStubInterface, attrName string) (string, bool, error) {
    val, found, err := cid.GetAttributeValue(stub, attrName)
    if err != nil {
        return "", false, fmt.Errorf("failed to get attribute %s: %w", attrName, err)
    }
    return val, found, nil
}

// IdentityContext is a summary of the user's identity for easier mocking and testing.
type IdentityContext struct {
    MSPID      string
    ID         string
    Attributes map[string]string
}

// GetIdentityContext returns a simplified identity context with MSP ID, user ID, and a sample "role" attribute.
func GetIdentityContext(stub shim.ChaincodeStubInterface) (*IdentityContext, error) {
    mspid, err := GetMSPID(stub)
    if err != nil {
        return nil, err
    }
    id, err := GetUserID(stub)
    if err != nil {
        return nil, err
    }

    // Example: retrieve a "role" attribute.
    role, _, _ := GetAttributeValue(stub, "role")

    return &IdentityContext{
        MSPID: mspid,
        ID:    id,
        Attributes: map[string]string{
            "role": role,
        },
    }, nil
}
