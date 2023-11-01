const mongoose = require('mongoose');

const CommunityMetricsSchema = new mongoose.Schema({
    creatorId: mongoose.Schema.Types.ObjectId,
    attributes: [{
        artForm: String, // e.g., Music, Podcast, etc.
        genre: String,   // e.g., Hip Hop, Lifestyle, etc.
    }],
    communityStrength: {
        communitySize: Number,
        groupChatActivity: Number,
        contentInteractivity: Number,
        hodlVsSellPressure: Number
    }
});

module.exports = mongoose.model('CommunityMetrics', CommunityMetricsSchema);
