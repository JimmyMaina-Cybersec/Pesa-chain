/**
 * Node.js script to import cryptomaterial from directory structure into MongoDB.
 * Each file is stored as an individual document with metadata.
 *
 * Requirements:
 * - Recursively traverse three base directories.
 * - Read file content as text (securely stored).
 * - Store metadata (file name, relative path, extension, created/updated dates).
 * - Infer organization name from file path.
 * - Use detailed logging and error handling.
 * - Connect securely using the provided MongoDB connection string.
 */

import fs from "fs";
import path from "path";
import { MongoClient } from "mongodb";
import logger from "../../logger";

// MongoDB connection details
const mongoURI =
  "mongodb+srv://jimmymainacybersec:2FU6M4loRe5pSE3W@pesachain-test.qyxf0.mongodb.net/?retryWrites=true&w=majority&appName=Pesachain-Test";
const dbName = "PesachainTest";
const collectionName = "Crypto Material";

// Base directories to process (adjust paths as needed)
const baseDirectories = [
  path.resolve("./Pesachain/crypto-config-ca/"),
  path.resolve("./org2/crypto-config-ca/"),
  path.resolve("./orderer/crypto-config-ca/"),
];

/**
 * Recursively traverse a directory and return an array of full file paths.
 * @param {string} dir - The directory to traverse.
 * @returns {Promise<string[]>} - An array of file paths.
 */
async function traverseDirectory(dir) {
  let filesList = [];
  try {
    const entries = await fs.promises.readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        filesList = filesList.concat(await traverseDirectory(fullPath));
      } else if (entry.isFile()) {
        filesList.push(fullPath);
      }
    }
  } catch (err) {
    logger.error(`Error reading directory ${dir}:`, err);
  }
  return filesList;
}

/**
 * Process a file by reading its content and file metadata.
 * Also infers the organization name from the file path.
 * @param {string} filePath - The full path of the file.
 * @returns {Promise<Object>} - Document to be inserted into MongoDB.
 */
async function processFile(filePath) {
  try {
    const stats = await fs.promises.stat(filePath);
    // Read file content as UTF-8 text.
    const content = await fs.promises.readFile(filePath, "utf8");

    // Infer organization name based on the file path
    let org = "unknown";
    if (filePath.includes("pesachain.com")) {
      org = "pesachain.com";
    } else if (filePath.includes("org2.example.com")) {
      org = "org2.example.com";
    } else if (filePath.includes("orderer.com")) {
      org = "orderer.com";
    }

    // Build and return the document
    return {
      org,
      fileName: path.basename(filePath),
      relativePath: filePath, // Could adjust to store path relative to a base if needed.
      extension: path.extname(filePath),
      content, // Stored as text
      createdAt: stats.birthtime, // Creation date
      updatedAt: stats.mtime, // Last modified date
    };
  } catch (err) {
    logger.error(`Error processing file ${filePath}:`, err);
    throw err; // Rethrow to handle in caller
  }
}

/**
 * Main function to connect to MongoDB, traverse directories,
 * process files, and insert documents.
 */
async function main() {
  const client = new MongoClient(mongoURI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });

  try {
    await client.connect();
    logger.info("Connected securely to MongoDB.");

    const db = client.db(dbName);
    const collection = db.collection(collectionName);

    // Loop over each base directory
    for (const baseDir of baseDirectories) {
      logger.info(`Processing directory: ${baseDir}`);
      const filePaths = await traverseDirectory(baseDir);
      logger.info(`Found ${filePaths.length} file(s) in ${baseDir}.`);

      for (const filePath of filePaths) {
        try {
          const doc = await processFile(filePath);
          // Insert the document into MongoDB
          await collection.insertOne(doc);
          logger.info(`Inserted document for file: ${filePath}`);
        } catch (fileErr) {
          logger.error(`Failed to process/insert file ${filePath}:`, fileErr);
        }
      }
    }
  } catch (err) {
    logger.error("An error occurred during processing:", err);
  } finally {
    await client.close();
    logger.info("MongoDB connection closed.");
  }
}

// Execute the main function
main().catch((err) => {
  logger.error("Fatal error:", err);
});
