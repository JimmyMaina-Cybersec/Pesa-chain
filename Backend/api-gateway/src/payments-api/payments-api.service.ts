import { Injectable } from '@nestjs/common';
import { CreatePaymentsApiDto } from './dto/create-payments-api.dto';
import { Gateway, Wallets, Contract } from 'fabric-network';
import { ConnectionProfile } from '../types/ConnectionProfile';
import * as path from 'path';
import * as fs from 'fs';

@Injectable()
export class PaymentsApiService {
  private gateway: Gateway;
  private contract: Contract;

  constructor() {
    this.gateway = new Gateway();
  }

  async init(orgIdentityKey: string) {
    // Load connection profile
    const ccpath = path.resolve(__dirname, '..', 'connection.json');
    const connectionProfileContent = fs.readFileSync(ccpath, 'utf8');
    const parsed: unknown = JSON.parse(connectionProfileContent);
    const ccp = parsed as ConnectionProfile;

    // Create a wallet (here, a file system wallet)
    const walletPath = path.join(process.cwd(), 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);

    // Get the identity dynamically
    const identity = await wallet.get(orgIdentityKey);
    if (!identity) {
      throw new Error('Identity not found in the wallet');
    }

    // Connecting to the gateway using the identity
    await this.gateway.connect(ccp as unknown as Record<string, unknown>, {
      wallet,
      identity: orgIdentityKey,
      discovery: { enabled: true, asLocalhost: true },
    });

    // Get the channel (network) and the chaincode (contract)
    const network = await this.gateway.getNetwork('payment-channel');
    this.contract = network.getContract('paymentccgo');
  }

  async create(
    createPaymentsApiDto: CreatePaymentsApiDto,
    orgIdentityKey: string,
  ) {
    // Initialize the connection dynamically for the incoming organization:
    await this.init(orgIdentityKey);

    // Now submit the transaction using the dynamic identity:
    await this.contract.submitTransaction(
      'CreateTransaction',
      createPaymentsApiDto.transactionID,
      createPaymentsApiDto.transactionType,
      createPaymentsApiDto.sender,
      createPaymentsApiDto.receiver,
      createPaymentsApiDto.amount.toString(),
      createPaymentsApiDto.currency,
      createPaymentsApiDto.recipientCert,
    );

    // Optionally, disconnect after successful transaction:
    this.disconnect();

    return { message: 'Transaction submitted successfully' };
  }

  findAll() {
    return `This action returns all paymentsApi`;
  }

  findOne(id: number) {
    return `This action returns a #${id} paymentsApi`;
  }

  disconnect() {
    this.gateway.disconnect();
  }
}
