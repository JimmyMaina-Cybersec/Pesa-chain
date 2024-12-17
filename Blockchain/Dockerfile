FROM hyperledger/fabric-ca:1.5

# Set environment variables
ENV FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
ENV FABRIC_CA_SERVER_CA_NAME=ca.pesachain.com
ENV FABRIC_CA_SERVER_TLS_ENABLED=true
ENV FABRIC_CA_SERVER_PORT=7054

# Copy the configuration files
COPY ./network/ca /etc/hyperledger/fabric-ca-server-config

# Set the entrypoint
ENTRYPOINT ["sh", "-c", "fabric-ca-server start -b admin:adminpw -d"]

# Expose the necessary port
EXPOSE 7054
