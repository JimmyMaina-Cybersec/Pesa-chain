import { IsString, IsNumber } from 'class-validator';

export class CreatePaymentsApiDto {
  @IsString()
  transactionType: string;

  @IsString()
  sender: string;

  @IsString()
  receiver: string;

  @IsNumber()
  amount: number;

  @IsString()
  currency: string;
}
