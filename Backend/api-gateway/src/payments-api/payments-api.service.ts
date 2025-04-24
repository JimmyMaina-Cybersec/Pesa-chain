import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { CreatePaymentsApiDto } from './dto/create-payments-api.dto';
import { Gateway, Wallets, X509Identity, Contract } from 'fabric-network';
import { ConnectionProfile } from '../types/ConnectionProfile';
import * as path from 'path';
import * as fs from 'fs';

interface GatewayEntry {
  gateway: Gateway;
  contract: Contract;
  certMTime: number;
  keyMTime: number;
}

@Injectable()
export class PaymentsApiService implements OnModuleDestroy {
  private gateways = new Map<string, GatewayEntry>();

  /**
   * Retrieves or initializes a cached GatewayEntry for the given identity.
   */
  private async getGatewayEntry(
    orgIdentityKey: string,
    mspId: string,
  ): Promise<GatewayEntry> {
    // Use a composite cache key, without altering the actual wallet path
    const cacheKey = `${mspId}::${orgIdentityKey}`;

    // Wallet directory remains under orgIdentityKey for Vault mounts
    const walletDir = path.join('/Vault/vault-secrets', orgIdentityKey);

    // Paths to MSP files
    const certPath = path.join(walletDir, 'msp', 'signcerts', 'cert.pem');
    const keyPath = path.join(walletDir, 'msp', 'keystore', 'prvKey.pem');

    // Ensure MSP files exist
    if (!fs.existsSync(certPath) || !fs.existsSync(keyPath)) {
      throw new Error(
        `MSP files not found for identity '${orgIdentityKey}' under MSP '${mspId}'`,
      );
    }

    // Check for certificate rotation via file modification times
    const certStat = fs.statSync(certPath);
    const keyStat = fs.statSync(keyPath);

    if (this.gateways.has(cacheKey)) {
      const entry = this.gateways.get(cacheKey)!;
      // If cert/key not modified since caching, reuse
      if (
        certStat.mtimeMs <= entry.certMTime &&
        keyStat.mtimeMs <= entry.keyMTime
      ) {
        return entry;
      }
      // Otherwise, refresh: disconnect and delete stale entry
      entry.gateway.disconnect();
      this.gateways.delete(cacheKey);
    }

    // 1) Load connection profile
    const ccpath = path.resolve(__dirname, '..', 'connection.json');
    const ccp = JSON.parse(
      fs.readFileSync(ccpath, 'utf8'),
    ) as ConnectionProfile;

    // 2) Point wallet at the Vault Agent–rendered MSP directory
    const wallet = await Wallets.newFileSystemWallet(walletDir);

    // 3) Read cert & key content
    const certificate = fs.readFileSync(certPath, 'utf8');
    const privateKey = fs.readFileSync(keyPath, 'utf8');

    // 4) Build the X509Identity
    const x509Identity: X509Identity = {
      credentials: { certificate, privateKey },
      mspId,
      type: 'X.509',
    };
    await wallet.put(orgIdentityKey, x509Identity);

    // 5) Connect the gateway
    const gateway = new Gateway();
    await gateway.connect(ccp as unknown as Record<string, unknown>, {
      wallet,
      identity: orgIdentityKey,
      discovery: { enabled: true, asLocalhost: true },
    });

    // 6) Get the contract
    const network = await gateway.getNetwork('payment-channel');
    const contract = network.getContract('paymentsControllerCC');

    // Cache the new entry with current mtime values
    const entry: GatewayEntry = {
      gateway,
      contract,
      certMTime: certStat.mtimeMs,
      keyMTime: keyStat.mtimeMs,
    };
    this.gateways.set(cacheKey, entry);
    return entry;
  }

  /**
   * Submits a payment dispatch transaction.
   */
  async create(
    createPaymentsApiDto: CreatePaymentsApiDto,
    orgIdentityKey: string,
    mspId: string,
  ) {
    const { contract } = await this.getGatewayEntry(orgIdentityKey, mspId);

    // Build the PaymentRequest payload
    const paymentRequest = {
      transactionType: createPaymentsApiDto.transactionType,
      payload: {
        sender: createPaymentsApiDto.sender,
        receiver: createPaymentsApiDto.receiver,
        amount: createPaymentsApiDto.amount.toString(),
        currency: createPaymentsApiDto.currency,
      },
    };

    // Submit transaction
    await contract.submitTransaction(
      'dispatchPayment',
      JSON.stringify(paymentRequest),
    );

    return { message: 'Transaction submitted successfully' };
  }

  findAll() {
    return `This action returns all paymentsApi`;
  }

  findOne(id: number) {
    return `This action returns a #${id} paymentsApi`;
  }

  /**
   * Clean up all gateways on application shutdown.
   */
  onModuleDestroy() {
    for (const { gateway } of this.gateways.values()) {
      gateway.disconnect();
    }
  }
}
