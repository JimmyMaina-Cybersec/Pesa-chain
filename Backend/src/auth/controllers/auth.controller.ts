import { Controller, Post, UseGuards, Request } from '@nestjs/common';
import { AuthService } from '../services/auth.service';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('verify')
  @UseGuards(JwtAuthGuard)
  async verifyToken(@Request() req) {
    const identity = await this.authService.getOrCreateIdentity(req.user);
    return {
      user: req.user,
      identity: {
        mspId: identity.mspId,
        certificate: identity.certificate,
      },
    };
  }
}