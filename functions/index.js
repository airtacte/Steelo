const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");
const { Web3 } = require("web3");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Fetch the Polygon zkEVM testnet RPC URL from Firebase config
// Make sure to add this config variable via Firebase CLI or console
const config = functions.config().blockchain;
const zkEVMTestnetRPCURL = config.polygon_zkevm_testnet_rpc_url;

// Verify if the RPC URL is fetched correctly
console.log("RPC URL:", zkEVMTestnetRPCURL);

// Initialize web3 with the RPC URL
const web3 = zkEVMTestnetRPCURL ? new Web3(zkEVMTestnetRPCURL) : undefined;

// Verify Web3 initialization
if (!web3) {
  console.error("Web3 initialization failed. Check RPC URL configuration.");
} else {
  // Example to verify the Web3 connection
  web3.eth
    .getBlockNumber()
    .then((blockNumber) => {
      console.log("Current Block Number:", blockNumber);
    })
    .catch((error) => {
      console.error("Error fetching current block number:", error);
    });
}

// Initialize Express App
const app = express();
app.use(cors({ origin: true })); // Enable CORS for all origins

// Example Middleware for authentication or logging
const myMiddleware = (req, res, next) => {
  // Example logging middleware
  console.log(`Received ${req.method} request from ${req.ip} for ${req.url}`);
  // Proceed to next middleware or route handler
  next();
};

// Apply middleware to the Express app
app.use(myMiddleware);

// Cloud Function: Fetch data from Firestore "volume" collection
exports.getVolumeData = functions.https.onRequest(async (request, response) => {
  try {
    const snapshot = await admin.firestore().collection("volume").get();
    const data = snapshot.docs.map((doc) => doc.data());
    response.status(200).json(data);
  } catch (error) {
    console.error("Error fetching volume data:", error);
    response.status(500).send("Internal Server Error");
  }
});

// Cloud Function: Simple Hello World endpoint
exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});

// Express route: Simple GET route
app.get("/", (req, res) => {
  res.send("Hello World from Express!");
});

// Expose Express API as a single Cloud Function
exports.widgets = functions.https.onRequest(app);

// Example Web3 Usage: Fetch current block number
exports.getCurrentBlockNumber = functions.https.onRequest(
  async (request, response) => {
    try {
      const currentBlockNumber = await web3.eth.getBlockNumber();
      const messagePart1 = `Current Block Number on Polygon zkEVM Testnet: `;
      const fullMessage = messagePart1 + `${currentBlockNumber}`;
      response.send(fullMessage);
    } catch (error) {
      console.error("Failed to fetch current block number:", error);
      response.status(500).send("Internal Server Error");
    }
  }
);