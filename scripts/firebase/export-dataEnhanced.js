const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');
const fs = require('fs');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://steelo-testnet.firebaseio.com'
});

const db = admin.firestore();

const convertFirestoreData = (data) => {
  if (data instanceof admin.firestore.DocumentReference) {
    return `DocumentReference(${data.path})`;
  } else if (data instanceof admin.firestore.Timestamp) {
    return `Timestamp(${data.toDate().toISOString()})`;
  } else if (typeof data === 'object' && data !== null) {
    const convertedObject = {};
    for (const key in data) {
      convertedObject[key] = convertFirestoreData(data[key]);
    }
    return convertedObject;
  } else {
    return data;
  }
};

const exportData = async () => {
  try {
    const collections = await db.listCollections();
    const data = [];

    for (const collectionRef of collections) {
      const collectionSnapshot = await collectionRef.get();
      collectionSnapshot.forEach(doc => {
        const docData = convertFirestoreData(doc.data());
        data.push({ id: doc.id, ...docData });
      });
    }

    const jsonData = JSON.stringify(data, null, 2);
    fs.writeFileSync('firebaseDataEnhanced.json', jsonData);
    fs.writeFileSync('firebaseData.json', jsonData);
    console.log('Data exported successfully.');
  } catch (error) {
    console.error('Error exporting data:', error);
  }
};

exportData();