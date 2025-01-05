import os
import base64
import logging
from dotenv import load_dotenv
from pymongo import MongoClient, InsertOne

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Load environment variables
load_dotenv()

# MongoDB connection
connection_string = os.getenv("MONGO_URI")
client = MongoClient(connection_string)
db = client.get_database("PesaChain")

# Collections
orderer_collection = db["orderer_organizations"]
peer_collection = db["peer_organizations"]
user_collection = db["users"]
metadata_collection = db["general_metadata"]

# Base path
base_path = "../crypto-config"  # Update this path relative to the script's directory

# Helper function to read and encode file content
def read_file_content(file_path):
    try:
        with open(file_path, "rb") as file:
            return base64.b64encode(file.read()).decode("utf-8")
    except Exception as e:
        logging.error(f"Failed to read file {file_path}: {e}")
        return None

# Generic function to insert documents
def insert_documents(entity, base_path, collection):
    bulk_operations = []
    for root, dirs, files in os.walk(base_path):
        for file in files:
            file_path = os.path.join(root, file)
            relative_path = os.path.relpath(file_path, base_path)
            parts = relative_path.split(os.sep)
            entity_name = parts[1] if len(parts) > 1 else None
            section = "msp" if "msp" in parts else "tls"

            document = collection.find_one({"name": entity_name})
            if not document:
                document = {"entity": entity, "name": entity_name, "certificates": {"msp": {}, "tls": {}}}

            encoded_content = read_file_content(file_path)
            if encoded_content:
                key = file.split(".")[-1] if "." in file else "key"
                document["certificates"][section][file] = encoded_content
                bulk_operations.append(InsertOne(document))

                logging.info(f"Prepared insert for {file} ({entity_name})")

    if bulk_operations:
        try:
            collection.bulk_write(bulk_operations)
            logging.info(f"Bulk insert completed for {entity} documents")
        except Exception as e:
            logging.error(f"Bulk insert failed for {entity} documents: {e}")

# Function to insert Auth0 secrets
def insert_auth0_secrets():
    bulk_operations = []
    for key, value in os.environ.items():
        if key.startswith("AUTH0_"):
            document = {"key": key, "value": value}
            bulk_operations.append(InsertOne(document))
            logging.info(f"Prepared insert for Auth0 secret: {key}")

    if bulk_operations:
        try:
            metadata_collection.bulk_write(bulk_operations)
            logging.info("Bulk insert completed for Auth0 secrets")
        except Exception as e:
            logging.error(f"Bulk insert failed for Auth0 secrets: {e}")

# Main execution
if __name__ == "__main__":
    logging.info("Inserting orderer documents...")
    insert_documents("orderer", os.path.join(base_path, "ordererOrganizations"), orderer_collection)

    logging.info("Inserting peer documents...")
    insert_documents("peer", os.path.join(base_path, "peerOrganizations"), peer_collection)

    logging.info("Inserting user documents...")
    insert_documents("user", os.path.join(base_path, "ordererOrganizations/users"), user_collection)
    insert_documents("user", os.path.join(base_path, "peerOrganizations/users"), user_collection)

    logging.info("Inserting Auth0 secrets...")
    insert_auth0_secrets()

    logging.info("All data inserted successfully!")
