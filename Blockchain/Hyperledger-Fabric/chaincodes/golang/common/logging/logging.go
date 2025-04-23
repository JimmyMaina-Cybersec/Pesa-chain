package logging

import (
	"log"
	"os"
	"time"
)

// Initialize a logger
var logger = log.New(os.Stdout, "", log.LstdFlags)

func LogTxStart(txID, functionName string) {
	logger.Printf("[START] %s | TxID: %s | Time: %s\n", functionName, txID, time.Now().Format(time.RFC3339))
}

func LogTxEnd(txID, functionName string) {
	logger.Printf("[END]   %s | TxID: %s | Time: %s\n", functionName, txID, time.Now().Format(time.RFC3339))
}

func LogError(txID, functionName string, err error) {
	if err != nil {
		logger.Printf("[ERROR] %s | TxID: %s | Time: %s | Error: %s\n", functionName, txID, time.Now().Format(time.RFC3339), err.Error())
	} else {
		logger.Printf("[ERROR] %s | TxID: %s | Time: %s | Error: No error provided\n", functionName, txID, time.Now().Format(time.RFC3339))
	}
}

// Optional: Add a function to configure file logging (if needed in production)
func SetLogFile(filePath string) error {
	file, err := os.OpenFile(filePath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0666)
	if err != nil {
		return err
	}
	logger.SetOutput(file)
	return nil
}
