import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Auth0User, FabricIdentity } from '../interfaces/auth.interface';
import { VaultService } from './vault.service';
import { FabricCAService } from './fabric-ca.service';

@Injectable()
export class AuthService {
  constructor(
    private configService: ConfigService,
    private jwtService: JwtService,
    private vaultService: VaultService,
    private fabricCAService: FabricCAService,
  ) {}

  async validateToken(token: string): Promise<Auth0User> {
    const decoded = await this.jwtService.verifyAsync(token, {
      issuer: `https://${this.configService.get('auth0.domain')}/`,
      audience: this.configService.get('auth0.audience'),
    });

    return decoded as Auth0User;
  }

  async getOrCreateIdentity(user: Auth0User): Promise<FabricIdentity> {
    // Check Vault first
    const identity = await this.vaultService.getIdentity(user.sub);
    if (identity) {
      return identity;
    }

    // Create new identity if not found
    const attrs = this.mapRolesToAttributes(user.roles);
    const newIdentity = await this.fabricCAService.enrollUser(user.sub, attrs);

    // Store in Vault
    await this.vaultService.storeIdentity(user.sub, newIdentity);

    return newIdentity;
  }

  private mapRolesToAttributes(roles: string[]): { name: string; value: string; ecert?: boolean }[] {
  // Define a direct mapping for roles to their respective attributes
    const roleToAttributesMapping = {
      'Chief Executive Officer (CEO)': [
        { name: 'role', value: 'chief executive officer', ecert: true },
        { name: 'affiliation', value: 'executive', ecert: true },
      ],
      'Chief Technical Officer (CTO)': [
        { name: 'role', value: 'chief technical officer', ecert: true },
        { name: 'affiliation', value: 'executive', ecert: true },
      ],
      'Chief Compliance Officer': [
        { name: 'role', value: 'chief compliance officer', ecert: true },
        { name: 'affiliation', value: 'compliance & risk management', ecert: true },
      ],
      'Compliance Analyst': [
        { name: 'role', value: 'compliance analyst', ecert: true },
        { name: 'affiliation', value: 'compliance & risk management', ecert: true },
      ],
      'Risk and Fraud Manager': [
        { name: 'role', value: 'risk and fraud manager', ecert: true },
        { name: 'affiliation', value: 'security', ecert: true },
      ],
      'Backend Developer': [
        { name: 'role', value: 'backend developer', ecert: true },
        { name: 'affiliation', value: 'technical', ecert: true },
      ],
      'Frontend Developer': [
        { name: 'role', value: 'frontend developer', ecert: true },
        { name: 'affiliation', value: 'technical', ecert: true },
      ],
      'DevSecOps Engineer': [
        { name: 'role', value: 'devsecops', ecert: true },
        { name: 'affiliation', value: 'technical', ecert: true },
      ],
      'Legal Counsel': [
        { name: 'role', value: 'legal counsel', ecert: true },
        { name: 'affiliation', value: 'legal', ecert: true },
      ],
      'Product Manager': [
        { name: 'role', value: 'product manager', ecert: true },
        { name: 'affiliation', value: 'business development & strategy', ecert: true },
      ],
      'Marketing Manager': [
        { name: 'role', value: 'marketing manager', ecert: true },
        { name: 'affiliation', value: 'business development & strategy', ecert: true },
      ],
      'Sales Manager': [
        { name: 'role', value: 'sales manager', ecert: true },
        { name: 'affiliation', value: 'business development & strategy', ecert: true },
      ],
      'Customer Support Manager': [
        { name: 'role', value: 'customer support manager', ecert: true },
        { name: 'affiliation', value: 'it & support', ecert: true },
      ],
    };

    const attrs: { name: string; value: string; ecert?: boolean }[] = [];

    // Iterate through the user's roles and find matching attributes
    for (const role of roles) {
      if (roleToAttributesMapping[role]) {
        attrs.push(...roleToAttributesMapping[role]);
      }
    }

    return attrs;
  }
}