const ethers = require('ethers');
const firebase = require('firebase/app');
require('firebase/firestore');

// Firebase configuration extracted from Steelo's Tech Stack document
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FIREBASE_APP_ID,
  measurementId: process.env.REACT_APP_FIREBASE_MEASUREMENT_ID
};

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
    const doc = await db.collection('creators').doc(creatorId).get();
    if (doc.exists) {
      return doc.data();
    } else {
      console.error('No such document!');
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
  handleError
};