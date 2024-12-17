package utils

import (
    "fmt"
    "regexp"
)

func ValidateCurrency(currency string) error {
    if len(currency) != 3 {
        return fmt.Errorf("invalid currency code length: %s", currency)
    }
    
    match, err := regexp.MatchString("^[A-Z]{3}$", currency)
    if err != nil {
        return err
    }
    if !match {
        return fmt.Errorf("invalid currency code format: %s", currency)
    }
    
    return nil
}

func ValidateAmount(amount float64) error {
    if amount <= 0 {
        return fmt.Errorf("amount must be greater than 0")
    }
    return nil
}

func ValidateBankID(bankID string) error {
    if len(bankID) == 0 {
        return fmt.Errorf("bank ID cannot be empty")
    }
    
    match, err := regexp.MatchString("^[A-Z0-9]{8,11}$", bankID)
    if err != nil {
        return err
    }
    if !match {
        return fmt.Errorf("invalid bank ID format: %s", bankID)
    }
    
    return nil
}