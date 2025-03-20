import { Module } from '@nestjs/common';
import { PaymentsApiService } from './payments-api.service';
import { PaymentsApiController } from './payments-api.controller';

@Module({
  controllers: [PaymentsApiController],
  providers: [PaymentsApiService],
})
export class PaymentsApiModule {}
