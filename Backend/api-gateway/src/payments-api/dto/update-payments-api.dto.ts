import { PartialType } from '@nestjs/mapped-types';
import { CreatePaymentsApiDto } from './create-payments-api.dto';

export class UpdatePaymentsApiDto extends PartialType(CreatePaymentsApiDto) {}
