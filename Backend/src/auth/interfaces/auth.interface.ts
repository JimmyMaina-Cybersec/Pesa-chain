export interface Auth0User {
  sub: string;
  email: string;
  roles: string[];
  permissions: string[];
}

export interface FabricIdentity {
  certificate: string;
  privateKey: string;
  mspId: string;
}

export interface RoleMapping {
  auth0Role: string;
  fabricAttrs: {
    name: string;
    value: string;
    ecert?: boolean;
  }[];
}