export class CreatePaymentsApiDto {
  transactionID: string;
  transactionType: string;
  sender: string;
  receiver: string;
  amount: number;
  currency: string;
  recipientCert: string;
}
