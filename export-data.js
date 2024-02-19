const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const fs = require('fs');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://firestore.googleapis.com/v1/projects/steelo-47/databases/(default)/documents'
});

// Access Firestore database
const db = admin.firestore();

// Fetch data from Firestore
const fetchData = async () => {
  try {
    const snapshot = await db.collection('Investor').get();
    const data = snapshot.docs.map(doc => doc.data());
    return data;
  } catch (error) {
    console.error('Error fetching data:', error);
    return null;
  }
};

// Export data
const exportData = async () => {
  const data = await fetchData();
  if (data) {
    const jsonData = JSON.stringify(data, null, 2);
    fs.writeFileSync('firebaseData.json', jsonData);
  }
};

// Call exportData function
exportData();
