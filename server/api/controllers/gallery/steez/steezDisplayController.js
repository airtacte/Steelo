const { getFirestore } = require('firebase-admin/firestore');

exports.displaySteez = async (req, res) => {
  const db = getFirestore();
  const steezId = req.params.steezId;
  
  try {
    const steezDoc = await db.collection('steez').doc(steezId).get();
    if (!steezDoc.exists) {
      return res.status(404).json({ message: 'Steez not found.' });
    }
    res.status(200).json(steezDoc.data());
  } catch (error) {
    res.status(500).json({ message: 'Error displaying Steez.', error: error.message });
  }
};