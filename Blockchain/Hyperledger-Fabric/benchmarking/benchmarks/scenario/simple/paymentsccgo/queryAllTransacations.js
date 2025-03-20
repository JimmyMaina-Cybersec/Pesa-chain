"use strict";

const { WorkloadModuleBase } = require("@hyperledger/caliper-core");

class QueryAllTransactionsWorkload extends WorkloadModuleBase {
  constructor() {
    super();
  }

  /**
   * submitTransaction is called by Caliper to send a transaction proposal.
   */
  async submitTransaction() {
    // Prepare a request to query all transactions from the public ledger.
    const request = {
      contractId: "paymentccgo", // Your chaincode name
      contractFunction: "QueryAllTransactions", // Function to query all transactions
      invokerIdentity: this.workerIndex, // Optional: worker-specific identity index
      contractArguments: [], // No arguments are needed for this function
    };

    // Submit the request to the Fabric SUT adapter.
    await this.sutAdapter.sendRequests(request);
  }
}

/**
 * createWorkloadModule creates a new instance of the workload module.
 */
function createWorkloadModule() {
  return new QueryAllTransactionsWorkload();
}

module.exports.createWorkloadModule = createWorkloadModule;
