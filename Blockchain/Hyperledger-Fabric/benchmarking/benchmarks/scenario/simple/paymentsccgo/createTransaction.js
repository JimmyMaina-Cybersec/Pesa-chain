"use strict";

const { WorkloadModuleBase } = require("@hyperledger/caliper-core");

class CreateTransactionWorkload extends WorkloadModuleBase {
  constructor() {
    super();
  }

  async submitTransaction() {
    // Retrieve transaction parameters from worker arguments.
    // These can be set in your Caliper benchmark YAML config.
    const txnId = this.workerArguments.transactionID || "TXN3";
    const txnType = this.workerArguments.transactionType || "EFT";
    const sender = this.workerArguments.sender || "Alice";
    const receiver = this.workerArguments.receiver || "Bob";
    // Ensure amount is passed as a string.
    const amount = this.workerArguments.amount
      ? String(this.workerArguments.amount)
      : "100.0";
    const currency = this.workerArguments.currency || "USD";

    const request = {
      contractId: "paymentccgo",
      contractFunction: "CreateTransaction",
      invokerIdentity: this.workerIndex,
      // Order of arguments should match the chaincode function signature:
      // CreateTransaction(ctx, transactionID, transactionType, sender, receiver, amount, currency)
      contractArguments: [txnId, txnType, sender, receiver, amount, currency],
    };

    await this.sutAdapter.sendRequests(request);
  }
}

function createWorkloadModule() {
  return new CreateTransactionWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;
