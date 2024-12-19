import { Injectable } from '@nestjs/common';
import { VaultService } from '../../auth/services/vault.service';

@Injectable()
export class SecretsService {
  constructor(private vaultService: VaultService) {}

  private readonly SECRETS_PATH = 'pesachain/secrets';
  private readonly CA_SECRETS_PATH = 'pesachain/ca';
  private readonly CERT_PATH = 'pesachain/certificates';

  async read<T>(path: string): Promise<T> {
    const secret = await this.vaultService.getVaultClient().read(path);
    return secret.data as T;
  }

  async write<T>(path: string, data: T): Promise<void> {
    await this.vaultService.getVaultClient().write(path, data);
  }

  async getCACredentials(): Promise<{ username: string; password: string }> {
    return this.read(`${this.CA_SECRETS_PATH}/admin`);
  }

  async storeCACredentials(username: string, password: string): Promise<void> {
    await this.write(`${this.CA_SECRETS_PATH}/admin`, {
      username,
      password,
    });
  }

  async getAuth0Credentials(): Promise<{
    domain: string;
    clientId: string;
    clientSecret: string;
  }> {
    return this.read(`${this.SECRETS_PATH}/auth0`);
  }

  async getTLSCertificates(): Promise<{
    cert: string;
    key: string;
    ca: string;
  }> {
    return this.read(`${this.SECRETS_PATH}/tls`);
  }
}
