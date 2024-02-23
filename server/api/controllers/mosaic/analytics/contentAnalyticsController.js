const { getFirestore } = require('firebase-admin/firestore');

exports.getContentAnalytics = async (req, res) => {
  const contentId = req.params.contentId;
  const db = getFirestore();

  try {
    const analyticsData = await db.collection('contentAnalytics').doc(contentId).get();
    if (!analyticsData.exists) {
      return res.status(404).json({ message: 'Analytics data not found for the specified content.' });
    }
    res.status(200).json(analyticsData.data());
  } catch (error) {
    res.status(500).json({ message: 'Failed to retrieve content analytics.', error: error.message });
  }
};