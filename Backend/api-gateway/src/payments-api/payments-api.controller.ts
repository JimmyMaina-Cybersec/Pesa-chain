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
    // Extract organization identity key and mspId from the request user payload.
    const user = req.user as {
      organizationIdentityKey?: string;
      mspId?: string;
    };
    const orgIdentityKey = user.organizationIdentityKey;
    const mspId = user.mspId;

    if (!orgIdentityKey) {
      throw new HttpException(
        'Organization identity key not found',
        HttpStatus.BAD_REQUEST,
      );
    }

    if (!mspId) {
      throw new HttpException('MSP ID not found', HttpStatus.BAD_REQUEST);
    }

    // Pass DTO, orgIdentityKey, and mspId explicitly to the service.
    return await this.paymentsApiService.create(
      createPaymentsApiDto,
      orgIdentityKey,
      mspId,
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
