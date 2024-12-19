import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as vault from 'node-vault';
import { FabricIdentity } from '../interfaces/auth.interface';

@Injectable()
export class VaultService {
  private vaultClient: vault.client;

  constructor(private configService: ConfigService) {
    this.initVaultClient();
  }

  private initVaultClient() {
    this.vaultClient = vault({
      apiVersion: 'v1',
      endpoint: this.configService.get('vault.address'),
      token: this.configService.get('vault.token'),
    });
  }

  public getVaultClient(): vault.client {
    return this.vaultClient;
  }

  async getIdentity(userId: string): Promise<FabricIdentity | null> {
    try {
      const path = `${this.configService.get('vault.mount')}/${this.configService.get('vault.certPath')}/${userId}`;
      const result = await this.getVaultClient().read(path);
      return result.data as FabricIdentity;
    } catch (error) {
      if (error.response?.statusCode === 404) {
        return null;
      }
      throw error;
    }
  }

  async storeIdentity(userId: string, identity: FabricIdentity): Promise<void> {
    const path = `${this.configService.get('vault.mount')}/${this.configService.get('vault.certPath')}/${userId}`;
    await this.getVaultClient().write(path, identity);
  }
}
