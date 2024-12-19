import { registerAs } from '@nestjs/config';

export default registerAs('fabric', () => ({
  caUrl: process.env.FABRIC_CA_URL || 'https://ca.pesachain.com:7054',
  caName: process.env.FABRIC_CA_NAME || 'ca.pesachain.com',
  walletPath: process.env.FABRIC_WALLET_PATH || './wallet',
  connectionProfile: process.env.FABRIC_CONNECTION_PROFILE || './connection.json',
  mspId: process.env.FABRIC_MSP_ID || 'PesachainMSP',
}));