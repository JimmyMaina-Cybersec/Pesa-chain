package fees

import "math"

func CalculateFlatFee(base float64) float64 {
	return math.Round(base*100) / 100 // Round to 2dp
}

func CalculatePercentageFee(amount float64, rate float64) float64 {
	return math.Round(amount*rate*100) / 100
}

// Use Case: Tiered, conditional logic can be added here
