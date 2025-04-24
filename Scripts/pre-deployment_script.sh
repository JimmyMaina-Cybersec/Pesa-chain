#!/usr/bin/env python3
"""
Pre-deployment Fabric Network Validation Script (Container Mode with Exponential Backoff)

This script performs a series of checks to validate that a Hyperledger Fabric network
running as Docker containers is properly configured and accessible. It checks:
  - That critical configuration and crypto artifacts exist.
  - MSP directories and certificate expiration.
  - Connectivity to Fabric Orderer and Peer nodes (by hitting their container endpoints).
  - Docker container health via Docker CLI.
  - A simulated chaincode transaction through the peer CLI.

All connectivity checks implement an exponential backoff strategy.
This script is designed to run in your CI pipeline after the containers have been started.
"""

import os
import sys
import subprocess
import logging
import socket
import time
from datetime import datetime

# Configure logging format
logging.basicConfig(format='[%(levelname)s] %(message)s', level=logging.INFO)
ERRORS = []  # Global collection of errors found

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------
def run_command(cmd, cwd=None, timeout=30):
    """Execute a shell command and return (exit_code, stdout, stderr)."""
    try:
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd=cwd, timeout=timeout)
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return 1, '', str(e)

def check_path_exists(path, description=""):
    """Check if the given path exists."""
    if not os.path.exists(path):
        error_msg = f"Missing {description} at path: {path}"
        logging.error(error_msg)
        ERRORS.append(error_msg)
        return False
    logging.info(f"Verified {description}: {path}")
    return True

def check_certificate(cert_path):
    """Check if a certificate exists and is not expired using openssl."""
    if not check_path_exists(cert_path, "certificate"):
        return
    cmd = ['openssl', 'x509', '-enddate', '-noout', '-in', cert_path]
    code, stdout, stderr = run_command(cmd)
    if code != 0:
        error_msg = f"Error reading certificate at {cert_path}: {stderr}"
        logging.error(error_msg)
        ERRORS.append(error_msg)
        return
    try:
        # Extract expiry date from output like: "notAfter=Feb 15 12:00:00 2026 GMT"
        expiry_str = stdout.split('=')[1].strip()
        expiry_date = datetime.strptime(expiry_str, "%b %d %H:%M:%S %Y %Z")
        if expiry_date < datetime.utcnow():
            error_msg = f"Certificate at {cert_path} is expired as of {expiry_date}."
            logging.error(error_msg)
            ERRORS.append(error_msg)
        else:
            logging.info(f"Certificate at {cert_path} is valid until {expiry_date}.")
    except Exception as e:
        error_msg = f"Unable to parse certificate expiry for {cert_path}: {e}"
        logging.error(error_msg)
        ERRORS.append(error_msg)

def exponential_backoff(func, *args, initial_delay=2, factor=2, max_attempts=5, **kwargs):
    """Generic exponential backoff wrapper for functions that return True on success."""
    delay = initial_delay
    for attempt in range(1, max_attempts + 1):
        if func(*args, **kwargs):
            logging.info(f"Success on attempt {attempt} for {func.__name__}")
            return True
        else:
            logging.warning(f"Attempt {attempt} failed for {func.__name__}. Retrying in {delay} seconds...")
            time.sleep(delay)
            delay *= factor
    return False

def check_host_port(host, port, description=""):
    """Check connectivity to a host and port using socket connection."""
    try:
        with socket.create_connection((host, port), timeout=5):
            logging.info(f"Connection successful to {description} at {host}:{port}")
            return True
    except Exception as e:
        logging.error(f"Unable to connect to {description} at {host}:{port} - {e}")
        return False

def check_docker_container(container_name):
    """Verify that a Docker container is running and healthy."""
    cmd = ['docker', 'inspect', '--format', '{{.State.Health.Status}}', container_name]
    code, stdout, stderr = run_command(cmd)
    if code != 0:
        error_msg = f"Failed to inspect Docker container '{container_name}': {stderr}"
        logging.error(error_msg)
        ERRORS.append(error_msg)
        return False

    if stdout.lower() != "healthy":
        error_msg = f"Docker container '{container_name}' is not healthy; reported status: '{stdout}'."
        logging.error(error_msg)
        ERRORS.append(error_msg)
        return False

    logging.info(f"Docker container '{container_name}' is healthy.")
    return True

def check_msp_directories(msp_paths):
    """Check that required MSP directories exist and contain necessary files."""
    required_subdirs = ['cacerts', 'signcerts', 'keystore']
    for org, path in msp_paths.items():
        if not check_path_exists(path, f"MSP for {org}"):
            continue
        for sub in required_subdirs:
            sub_path = os.path.join(path, sub)
            if not check_path_exists(sub_path, f"{org} MSP subdirectory '{sub}'"):
                continue
            if not os.listdir(sub_path):
                error_msg = f"MSP subdirectory '{sub_path}' for {org} is empty."
                logging.error(error_msg)
                ERRORS.append(error_msg)
            else:
                logging.info(f"MSP subdirectory '{sub_path}' for {org} contains files.")

def simulate_chaincode_transaction(channel_name, chaincode_name, function, args, peer_env, tls_enabled=True):
    """
    Simulate a chaincode transaction using the peer CLI.
    Assumes that the necessary environment variables (CORE_PEER_*) are correctly set in peer_env.
    Performs a query (or a dry-run invoke if available) and checks for correct endorsement.
    """
    args_list = ",".join([f'\\"{arg}\\"' for arg in args])
    cmd = [
        'peer', 'chaincode', 'query',
        '-C', channel_name,
        '-n', chaincode_name,
        '-c', f'{{"Args":["{function}",{args_list}]}}'
    ]
    try:
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                text=True, env=peer_env, timeout=30)
    except Exception as e:
        error_msg = f"Error executing chaincode query: {e}"
        logging.error(error_msg)
        ERRORS.append(error_msg)
        return

    if result.returncode != 0:
        error_msg = f"Chaincode simulation failed: {result.stderr.strip()}"
        logging.error(error_msg)
        ERRORS.append(error_msg)
        logging.info("Advisory: Verify that chaincode is installed, endorsement policies are correct, and the channel is joined by all peers.")
    else:
        logging.info(f"Chaincode simulation succeeded: {result.stdout.strip()}")

# -----------------------------------------------------------------------------
# Validation for Container Endpoints (with Exponential Backoff)
# -----------------------------------------------------------------------------
def validate_orderers(orderer_endpoints):
    """
    Validate connectivity to each orderer endpoint.
    orderer_endpoints: list of tuples, e.g., [(host, port, "OrdererName"), ...]
    """
    for host, port, name in orderer_endpoints:
        if not exponential_backoff(check_host_port, host, port, description=f"Orderer node '{name}'"):
            ERRORS.append(f"Orderer node '{name}' at {host}:{port} is unreachable.")

def validate_peers(peer_endpoints):
    """
    Validate connectivity to each peer endpoint.
    peer_endpoints: list of tuples, e.g., [(host, port, "PeerName"), ...]
    """
    for host, port, name in peer_endpoints:
        if not exponential_backoff(check_host_port, host, port, description=f"Peer node '{name}'"):
            ERRORS.append(f"Peer node '{name}' at {host}:{port} is unreachable.")

# -----------------------------------------------------------------------------
# Main Function
# -----------------------------------------------------------------------------
def main():
    logging.info("Starting pre-deployment Fabric network validation (Container Mode)...")

    # 1. Check Configuration Files and Artifacts
    logging.info("Verifying configuration and crypto artifacts...")
    paths_to_check = {
        "Channel Artifacts": "./channel-artifacts",
        "Crypto Config": "./crypto-config"
    }
    for desc, path in paths_to_check.items():
        check_path_exists(path, desc)

    # 2. Check MSP Directories & Certificate Expiry for Organizations
    logging.info("Validating MSP and certificate materials for organizations...")
    msp_paths = {
        "Org1": "./crypto-config/org1/msp",
        "Org2": "./crypto-config/org2/msp"
    }
    check_msp_directories(msp_paths)

    sample_certs = {
        "Org1 CA": "./crypto-config/org1/msp/cacerts/ca.org1.example.com-cert.pem",
        "Org2 CA": "./crypto-config/org2/msp/cacerts/ca.org2.example.com-cert.pem"
    }
    for name, cert_path in sample_certs.items():
        check_certificate(cert_path)

    # 3. Validate Docker Container Health (Using Docker CLI)
    logging.info("Validating Docker container health statuses...")
    containers = [
        "orderer.example.com",
        "orderer2.example.com",
        "orderer3.example.com",
        "peer0.pesachain.com",
        "peer1.pesachain.com",
        "peer0.org2.example.com",
        "peer1.org2.example.com"
    ]
    for container in containers:
        exponential_backoff(check_docker_container, container)

    # 4. Validate Connectivity to Orderer and Peer Endpoints in Containers
    logging.info("Validating connectivity to Fabric Orderer nodes...")
    orderer_endpoints = [
        # Use the hostnames and exposed ports as defined in your compose file.
        ("orderer.example.com", 7050, "Orderer1"),
        ("orderer2.example.com", 8050, "Orderer2"),
        ("orderer3.example.com", 9050, "Orderer3")
    ]
    validate_orderers(orderer_endpoints)

    logging.info("Validating connectivity to Fabric Peer nodes...")
    peer_endpoints = [
        ("peer0.pesachain.com", 7051, "Peer0 Pesachain"),
        ("peer1.pesachain.com", 8051, "Peer1 Pesachain"),
        ("peer0.org2.example.com", 9051, "Peer0 Org2"),
        ("peer1.org2.example.com", 10051, "Peer1 Org2")
    ]
    validate_peers(peer_endpoints)

    # 5. Simulate a Chaincode Transaction
    logging.info("Simulating chaincode transaction to validate smart contract integrity...")
    # Configure environment variables for the peer CLI execution.
    peer_env = os.environ.copy()
    peer_env.update({
        "CORE_PEER_LOCALMSPID": "Org1MSP",
        "CORE_PEER_MSPCONFIGPATH": os.path.abspath("./crypto-config/org1/users/Admin@org1.example.com/msp"),
        "CORE_PEER_ADDRESS": "peer0.org1.example.com:7051",
        "CORE_PEER_TLS_ENABLED": "true",
        "CORE_PEER_TLS_ROOTCERT_FILE": os.path.abspath("./crypto-config/org1/peers/peer0.org1.example.com/tls/ca.crt")
    })

    simulate_chaincode_transaction(
        channel_name="mychannel",
        chaincode_name="mycc",
        function="queryAsset",
        args=["asset1"],
        peer_env=peer_env
    )

    # Final Reporting and Exit Status
    logging.info("Validation complete. Reviewing reported issues:")
    if ERRORS:
        logging.error("Issues were detected during pre-deployment validation:")
        for err in ERRORS:
            logging.error(f" - {err}")
        logging.error("Advisory: Please review and remediate the above issues before proceeding with deployment.")
        sys.exit(1)
    else:
        logging.info("All checks passed successfully. The Fabric network is ready for deployment.")

if __name__ == "__main__":
    main()
