package validation

import (
	"fmt"
	"unicode"
)

func ValidateAmount(amount float64) error {
	if amount <= 0 {
		return fmt.Errorf("amount must be greater than zero, got: %f", amount)
	}
	return nil
}

func ValidateCurrency(currency string) error {
	if len(currency) != 3 {
		return fmt.Errorf("invalid currency code length, expected 3 characters, got: %d", len(currency))
	}
	// Check that the currency code contains only uppercase alphabetic characters
	for _, c := range currency {
		if !unicode.IsUpper(c) {
			return fmt.Errorf("currency code must be uppercase, invalid character: %c", c)
		}
	}
	return nil
}
