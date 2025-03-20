export interface ConnectionProfile {
  name: string;
  version: string;
  'mutual-tls': boolean;
  info: {
    Version: string;
    Size: string;
    Orderer: string;
    Distribution: string;
    StateDB: string;
  };
  clients: {
    [clientId: string]: {
      client: {
        organization: string;
        credentialStore: {
          path: string;
          cryptoStore: {
            path: string;
          };
        };
        clientPrivateKey: {
          path: string;
        };
        clientSignedCert: {
          path: string;
        };
      };
    };
  };
  channels: {
    [channelName: string]: {
      created: boolean;
      orderers: string[];
      peers: {
        [peerName: string]: {
          eventSource: boolean;
        };
      };
      contracts: {
        id: string;
        version: string;
        language: string;
      }[];
    };
  };
  organizations: {
    [orgName: string]: {
      mspid: string;
      peers: string[];
      certificateAuthorities: string[];
      adminPrivateKey: {
        path: string;
      };
      signedCert: {
        path: string;
      };
    };
  };
  orderers: {
    [ordererName: string]: {
      url: string;
      grpcOptions: { [key: string]: any };
      tlsCACerts: { path: string };
    };
  };
  peers: {
    [peerName: string]: {
      url: string;
      grpcOptions: { [key: string]: any };
      tlsCACerts: { path: string };
    };
  };
  certificateAuthorities: {
    [caName: string]: {
      url: string;
      httpOptions: { verify: boolean };
      tlsCACerts: { path: string };
      registrar: {
        enrollId: string;
        enrollSecret: string;
      }[];
    };
  };
}
