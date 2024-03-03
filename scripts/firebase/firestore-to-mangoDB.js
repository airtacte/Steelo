const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');
const fs = require('fs');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://steelo-testnet.firebaseio.com'
});

const db = admin.firestore();

const convertTimestamps = (value) => {
  if (value && value.toDate) {
    return value.toDate().toISOString();
  }
  return value;
};

const convertReferences = (value) => {
  if (value && value.path) {
    return `/${value.path}`;
  }
  return value;
};

const processData = (data) => {
  return JSON.parse(JSON.stringify(data), (key, value) => {
    return convertTimestamps(convertReferences(value));
  });
};

const resolveReferences = async (docData) => {
  const data = {};
  for (const key in docData) {
    if (docData[key] instanceof admin.firestore.DocumentReference) {
      const referencePath = await docData[key].get();
      data[key] = referencePath.exists ? processData(referencePath.data()) : null; // Retrieve and process the referenced document data
    } else if (docData[key] instanceof admin.firestore.Timestamp) {
      data[key] = convertTimestamps(docData[key]); // Convert Timestamp to Date
    } else if (Array.isArray(docData[key])) {
      data[key] = await Promise.all(docData[key].map(async item => {
        if (item instanceof admin.firestore.DocumentReference) {
          const refPath = await item.get();
          return refPath.exists ? processData(refPath.data()) : null;
        }
        return convertTimestamps(convertReferences(item));
      }));
    } else if (typeof docData[key] === 'object' && docData[key] !== null) {
      data[key] = await resolveReferences(docData[key]); // Recursively process nested objects
    } else {
      data[key] = convertTimestamps(convertReferences(docData[key]));
    }
  }
  return data;
};

const exportData = async () => {
  try {
    const collections = await db.listCollections();
    const data = {};

    for (const collectionRef of collections) {
      const collectionSnapshot = await collectionRef.get();
      const docs = [];
      for (const doc of collectionSnapshot.docs) {
        const docData = await resolveReferences(doc.data());
        docs.push({ id: doc.id, ...docData });
      }
      data[collectionRef.id] = docs;
    }

    const jsonData = JSON.stringify(data, null, 2);
    fs.writeFileSync('firebaseDataEnhanced.json', jsonData);
    console.log('Data exported successfully.');
  } catch (error) {
    console.error('Error exporting data:', error);
  }
};

exportData();
