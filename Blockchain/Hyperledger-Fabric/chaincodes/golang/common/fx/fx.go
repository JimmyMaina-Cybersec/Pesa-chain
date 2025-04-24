package fx

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
)

const apiURL = "https://api.exchangerate-api.com/v4/latest/USD" // Replace with your chosen API's URL

// ExchangeRateResponse structure for parsing the JSON response
type ExchangeRateResponse struct {
	Rates map[string]float64 `json:"rates"`
}

// FetchExchangeRates fetches exchange rates from an API
// This function sends a GET request to the API and decodes the response into a map of currency rates.
func FetchExchangeRates() (map[string]float64, error) {
	resp, err := http.Get(apiURL) // Make sure to replace apiURL with your actual API endpoint
	if err != nil {
		return nil, err // Return the error if the request fails
	}
	defer resp.Body.Close()

	// If the API response status is not OK, return an error
	if resp.StatusCode != http.StatusOK {
		return nil, errors.New("failed to fetch exchange rates")
	}

	var exchangeData ExchangeRateResponse
	// Decode the JSON response into the ExchangeRateResponse struct
	if err := json.NewDecoder(resp.Body).Decode(&exchangeData); err != nil {
		return nil, err // Return the error if JSON decoding fails
	}

	return exchangeData.Rates, nil
}

// Convert converts amount from one currency to another using live exchange rates
// This function fetches the latest exchange rates and performs the conversion from one currency to another.
func Convert(from string, to string, amount float64) (float64, error) {
	// Basic validation for amount: Ensure the amount is greater than zero
	if amount <= 0 {
		return 0, errors.New("amount must be greater than zero")
	}

	// Normalize currency codes to uppercase to maintain consistency
	from = strings.ToUpper(from)
	to = strings.ToUpper(to)

	// Validate that the currency codes are in 3-character ISO 4217 format
	if len(from) != 3 || len(to) != 3 {
		return 0, errors.New("invalid currency code format")
	}

	// Fetch live exchange rates
	// This function will call the FetchExchangeRates function to get the latest rates from the API
	rates, err := FetchExchangeRates()
	if err != nil {
		return 0, err // Return the error if fetching rates fails
	}

	// Look for the exchange rate between from and to in the rates map
	fromRate, fromOk := rates[from]
	toRate, toOk := rates[to]

	// If the rates for the currencies are not available, return an error
	if !fromOk || !toOk {
		return 0, errors.New("unsupported currency pair")
	}

	// Convert the amount from `from` to USD and then to `to` currency
	// The formula here converts from the `from` currency to USD, then from USD to the `to` currency
	convertedAmount := amount * (toRate / fromRate)
	return convertedAmount, nil
}

// Important Notes:
//
// 1. You'll need to replace the apiURL with the actual URL for the API service you're using.
//
// 2. Most API services require you to sign up and get an API key for authentication (usually for premium access).
//
// 3. You may want to cache exchange rates to avoid making a request for every conversion,
//    especially if you're making frequent calls to the API. This can reduce overhead and improve performance.
