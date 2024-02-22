const { getFirestore } = require('firebase-admin/firestore');

const db = getFirestore();

// Retrieve analytics data for a specific asset
exports.getAssetAnalytics = async (req, res) => {
    const { assetId } = req.params;

    try {
        const analyticsData = await db.collection('analytics')
                                      .where('assetId', '==', assetId)
                                      .get();
        
        if (analyticsData.empty) {
            return res.status(404).send('No analytics data found for the specified asset.');
        }

        // Process and return analytics data
        // This example assumes a simple count of views and interactions
        let views = 0;
        let interactions = 0;
        analyticsData.forEach(doc => {
            views += doc.data().views || 0;
            interactions += doc.data().interactions || 0;
        });

        res.status(200).json({ assetId, views, interactions });
    } catch (error) {
        console.error('Error retrieving asset analytics:', error);
        res.status(500).send('Error retrieving analytics data.');
    }
};