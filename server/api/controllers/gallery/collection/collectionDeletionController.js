const { getFirestore } = require('firebase-admin/firestore');

exports.deleteCollection = async (req, res) => {
  const db = getFirestore();
  const { collectionId } = req.params;

  try {
    await db.collection('collections').doc(collectionId).delete();
    res.status(200).send({ message: 'Collection deleted successfully.' });
  } catch (error) {
    res.status(500).send({ message: 'Failed to delete collection.', error: error.message });
  }
};