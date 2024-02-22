const { getFirestore } = require('firebase-admin/firestore');

exports.displayRoyalties = async (req, res) => {
  try {
    const db = getFirestore();
    const royaltiesSnapshot = await db.collection('royalties').where('creatorId', '==', req.params.creatorId).get();
    
    if (royaltiesSnapshot.empty) {
      return res.status(404).send('No royalties found for the specified creator.');
    }
    
    let royalties = [];
    royaltiesSnapshot.forEach(doc => {
      royalties.push({ id: doc.id, ...doc.data() });
    });
    
    res.status(200).json(royalties);
  } catch (error) {
    console.error('Error displaying royalties:', error);
    res.status(500).send('Error retrieving royalty information.');
  }
};