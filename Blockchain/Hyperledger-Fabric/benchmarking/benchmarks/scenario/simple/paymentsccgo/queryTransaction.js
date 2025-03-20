"use strict";

const { WorkloadModuleBase } = require("@hyperledger/caliper-core");

class QueryTransactionWorkload extends WorkloadModuleBase {
  constructor() {
    super();
  }

  async submitTransaction() {
    // Retrieve parameters from the worker's configuration
    // Default values are provided if not set via the benchmark config.
    const txnId = this.workerArguments.transactionID || "TXN1";
    const txnType = this.workerArguments.transactionType || "EFT";

    const request = {
      contractId: "paymentccgo",
      contractFunction: "QueryTransaction",
      invokerIdentity: this.workerIndex,
      contractArguments: [txnId, txnType],
    };

    await this.sutAdapter.sendRequests(request);
  }
}

function createWorkloadModule() {
  return new QueryTransactionWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;
