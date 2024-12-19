import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import auth0Config from './auth/config/auth0.config';
import fabricConfig from './auth/config/fabric.config';
import vaultConfig from './auth/config/vault.config';
import { AuthController } from './auth/controllers/auth.controller';
import { AuthService } from './auth/services/auth.service';
import { FabricCAService } from './auth/services/fabric-ca.service';
import { VaultService } from './auth/services/vault.service';

@Module({
  imports: [
    ConfigModule.forRoot({
      load: [auth0Config, fabricConfig, vaultConfig],
      isGlobal: true,
    }),
    JwtModule.registerAsync({
      useFactory: async (configService) => ({
        secret: configService.get('auth0.clientSecret'),
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, FabricCAService, VaultService],
})
export class AppModule {}