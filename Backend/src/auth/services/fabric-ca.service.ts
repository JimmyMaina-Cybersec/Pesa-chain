import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as FabricCAServices from 'fabric-ca-client';
import { FabricIdentity } from '../interfaces/auth.interface';

@Injectable()
export class FabricCAService {
  private caClient: FabricCAServices;

  constructor(private configService: ConfigService) {
    this.initCAClient();
  }

  private initCAClient() {
    const caUrl = this.configService.get<string>('fabric.caUrl');
    const caName = this.configService.get<string>('fabric.caName');

    this.caClient = new FabricCAServices(caUrl, {
      trustedRoots: [],
      verify: false,
    },
    caName
    );
  }

  async enrollUser(
    userId: string,
    attrs: { name: string; value: string; ecert?: boolean }[],
  ): Promise<FabricIdentity> {
    const enrollment = await this.caClient.enroll({
      enrollmentID: userId,
      enrollmentSecret: 'temp-secret', // In production, use proper secret management
      attr_reqs: attrs.map(attr => ({
        name: attr.name,
        value: attr.value,
        optional: attr.ecert ?? false, // Set 'optional' based on 'ecert' or default to false
      })),
    });

    return {
      certificate: enrollment.certificate,
      privateKey: enrollment.key.toBytes(),
      mspId: this.configService.get('fabric.mspId'),
    };
  }
}