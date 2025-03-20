import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PaymentsApiController } from './payments-api/payments-api.controller';
import { PaymentsApiModule } from './payments-api/payments-api.module';

@Module({
  imports: [PaymentsApiModule],
  controllers: [AppController, PaymentsApiController],
  providers: [AppService],
})
export class AppModule {}
