import { Test, TestingModule } from '@nestjs/testing';
import { PaymentsApiService } from './payments-api.service';

describe('PaymentsApiService', () => {
  let service: PaymentsApiService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PaymentsApiService],
    }).compile();

    service = module.get<PaymentsApiService>(PaymentsApiService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
