const { getFirestore } = require('firebase-admin/firestore');

const db = getFirestore();

// Upgraded and enhanced analytics retrieval for Bazaar
exports.getAssetAnalytics = async (req, res) => {
    const { assetId } = req.params;

    try {
        // Directly reference the 'content' collection using assetId
        const contentDocRef = db.collection('Content').doc(assetId);
        const contentDoc = await contentDocRef.get();

        if (!contentDoc.exists) {
            return res.status(404).send('Content not found.');
        }

        // Assuming analytics are stored under a 'views' and 'interactions' subcollection for each content
        const viewsSnapshot = await contentDocRef.collection('views').get();
        const interactionsSnapshot = await contentDocRef.collection('interactions').get();

        // Process and return analytics data
        const views = viewsSnapshot.size; // Assuming each doc in 'views' represents a single view
        let interactions = 0;
        interactionsSnapshot.forEach(doc => {
            interactions += doc.data().count || 0; // Assuming 'count' field holds the number of interactions
        });

        // Fetch additional analytics data from 'analytics' collection
        const analyticsData = await db.collection('analytics')
                                      .where('assetId', '==', assetId)
                                      .get();

        let sales = 0; // Track sales
        let totalRevenue = 0; // Track revenue generated from sales
        let transactionVolume = 0; // Added: Track transaction volumes
        let liquidityPoolSize = 0; // Added: Track liquidity pool sizes
        let bidAskSpread = 0; // Added: Track bid-ask spreads

        analyticsData.forEach(doc => {
            const data = doc.data();
            sales += data.sales || 0; // Accumulate sales count
            totalRevenue += data.revenue || 0; // Accumulate total revenue
            transactionVolume += data.transactionVolume || 0; // Accumulate transaction volumes
            liquidityPoolSize += data.liquidityPoolSize || 0; // Accumulate liquidity pool sizes
            bidAskSpread += data.bidAskSpread || 0; // Accumulate bid-ask spreads
        });

        res.status(200).json({
            assetId,
            views,
            interactions,
            sales,
            totalRevenue,
            transactionVolume,
            liquidityPoolSize,
            bidAskSpread
        });
    } catch (error) {
        console.error('Error retrieving asset analytics:', error);
        res.status(500).send('Error retrieving analytics data.');
    }
};