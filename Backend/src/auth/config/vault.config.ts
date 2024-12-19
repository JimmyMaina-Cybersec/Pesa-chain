import { registerAs } from '@nestjs/config';

export default registerAs('vault', () => ({
  address: process.env.VAULT_ADDR || 'http://localhost:8200',
  token: process.env.VAULT_TOKEN,
  mount: process.env.VAULT_MOUNT || 'pesachain',
  certPath: process.env.VAULT_CERT_PATH || 'certificates',
}));