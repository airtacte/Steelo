const UserActivity = require('../../models/UserActivity');
const UserNetwork = require('../../models/UserNetwork');
const SentimentAnalysis = require('../../utils/SentimentAnalysis');
const TrendAnalysis = require('../../utils/TrendAnalysis');
const RecommendationEngine = require('../../utils/RecommendationEngine');

exports.getRecommendations = async (req, res) => {
  try {
    // Get the user's activities
    const userActivities = await UserActivity.find({ userId: req.user.id });

    // Get the user's network data
    const userNetwork = await UserNetwork.find({ userId: req.user.id });

    // Perform sentiment analysis on the user's comments
    const sentimentAnalysis = new SentimentAnalysis(userActivities);
    const sentimentData = await sentimentAnalysis.getSentimentData();

    // Perform trend analysis on the user's activities
    const trendAnalysis = new TrendAnalysis(userActivities);
    const trendData = await trendAnalysis.getTrendData();

    // Generate recommendations based on the user's activities, network data, sentiment data, and trend data
    const recommendationEngine = new RecommendationEngine(userActivities, userNetwork, sentimentData, trendData);
    const recommendations = await recommendationEngine.getRecommendations();

    res.json(recommendations);
  } catch (error) {
    res.status(500).send(error.message);
  }
};