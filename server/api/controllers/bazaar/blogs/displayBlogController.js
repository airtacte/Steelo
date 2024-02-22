const { getFirestore } = require('firebase-admin/firestore');

exports.displayBlog = async (req, res) => {
  try {
    const db = getFirestore();
    const doc = await db.collection('blogs').doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).send('Blog not found');
    }
    res.status(200).json(doc.data());
  } catch (error) {
    res.status(500).send('Error retrieving blog');
  }
};
