const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');
const fs = require('fs');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://steelo-testnet.firebaseio.com'
});

// Access Firestore database
const db = admin.firestore();

// Export data
const exportData = async () => {
  try {
    const collections = await db.listCollections();
    const data = [];

    for (const collectionRef of collections) {
      const collectionSnapshot = await collectionRef.get();
      collectionSnapshot.forEach(doc => {
        data.push({ id: doc.id, ...doc.data() });
      });
    }

    const jsonData = JSON.stringify(data, null, 2);
    // Save JSON data to a file
    fs.writeFileSync('firebaseData.json', jsonData);
    console.log('Data exported successfully.');
  } catch (error) {
    console.error('Error exporting data:', error);
  }
};

// Call exportData function
exportData();