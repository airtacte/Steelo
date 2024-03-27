const ethers = require("ethers");
const firebase = require("firebase/app");
require("firebase/firestore");

const { firebaseConfig } = require('./config/config.js');

// Initialize Firebase
if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
} else {
  firebase.app(); // if already initialized
}

const db = firebase.firestore();

// Convert Ethereum address to checksum address
function toChecksumAddress(address) {
  return ethers.utils.getAddress(address);
}

// Fetch creator profile from Firestore
async function fetchCreatorProfile(creatorId) {
  try {
    const doc = await db.collection("creators").doc(creatorId).get();
    if (doc.exists) {
      return doc.data();
    } else {
      console.error("No such document!");
      return null;
    }
  } catch (error) {
    console.error("Error fetching document:", error);
  }
}

// Simplified error handler for catching and logging errors
function handleError(error) {
  console.error("Error:", error.message);
}

module.exports = {
  toChecksumAddress,
  fetchCreatorProfile,
  handleError,
};