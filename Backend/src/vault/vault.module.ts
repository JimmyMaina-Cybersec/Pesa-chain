import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { VaultService } from '../auth/services/vault.service';
import { SecretsService } from './services/secrets.service';
import vaultConfig from '../auth/config/vault.config';

@Global()
@Module({
  imports: [
    ConfigModule.forFeature(vaultConfig),
  ],
  providers: [VaultService, SecretsService],
  exports: [VaultService, SecretsService],
})
export class VaultModule {}