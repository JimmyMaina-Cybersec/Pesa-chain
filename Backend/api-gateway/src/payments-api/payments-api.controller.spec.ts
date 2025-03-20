import { Test, TestingModule } from '@nestjs/testing';
import { PaymentsApiController } from './payments-api.controller';
import { PaymentsApiService } from './payments-api.service';

describe('PaymentsApiController', () => {
  let controller: PaymentsApiController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PaymentsApiController],
      providers: [PaymentsApiService],
    }).compile();

    controller = module.get<PaymentsApiController>(PaymentsApiController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
