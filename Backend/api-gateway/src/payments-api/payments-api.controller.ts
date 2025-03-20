import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  HttpException,
  HttpStatus,
  Req,
} from '@nestjs/common';
import { PaymentsApiService } from './payments-api.service';
import { CreatePaymentsApiDto } from './dto/create-payments-api.dto';
import { CustomRequest } from 'src/types/CustomRequest.interface';

@Controller('payments-api')
export class PaymentsApiController {
  constructor(private readonly paymentsApiService: PaymentsApiService) {}

  @Post('/createPayment')
  async createTransaction(
    @Body() createPaymentsApiDto: CreatePaymentsApiDto,
    @Req() req: CustomRequest,
  ) {
    const orgIdentityKey: string = (
      req.user as { organizationIdentityKey: string }
    ).organizationIdentityKey;
    if (!orgIdentityKey) {
      throw new HttpException(
        'Organization identity key not found',
        HttpStatus.BAD_REQUEST,
      );
    }
    // Pass both the DTO and the dynamic identity key to the service.
    return await this.paymentsApiService.create(
      createPaymentsApiDto,
      orgIdentityKey,
    );
  }

  @Get()
  findAll() {
    return this.paymentsApiService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.paymentsApiService.findOne(+id);
  }
}
