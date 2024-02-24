const admin = require('firebase-admin');

// Initialize Firestore
admin.initializeApp();
const db = admin.firestore();

exports.getUserHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const userHistoryRef = db.collection('userHistory').doc(userId);
    const doc = await userHistoryRef.get();

    if (!doc.exists) {
      res.status(404).send('No user history found');
    } else {
      res.json(doc.data());
    }
  } catch (error) {
    res.status(500).send(error.message);
  }
};

exports.clearHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const userHistoryRef = db.collection('userHistory').doc(userId);

    await userHistoryRef.set({ history: [] }, { merge: true });

    res.send('User history cleared successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
};