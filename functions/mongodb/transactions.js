const functions = require('firebase-functions');
const connectDB = require('./dbConnect');

exports.syncFirestoreToMongoDB = functions.firestore
  .document('transactions/{transactionId}')
  .onCreate(async (snapshot, context) => {
    const transactionData = snapshot.data();
    const db = await connectDB();
    const transactionsCollection = db.collection('transactions');

    try {
      await transactionsCollection.insertOne(transactionData);
      console.log('Synced to MongoDB');
    } catch (error) {
      console.error('Error syncing to MongoDB', error.message);
    }
  });