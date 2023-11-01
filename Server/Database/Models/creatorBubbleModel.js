const mongoose = require('mongoose');

const CreatorBubbleSchema = new mongoose.Schema({
    name: String,  // Name of this creator bubble
    primaryCreator: mongoose.Schema.Types.ObjectId, // main creator ID
    relatedCreators: [{
        creatorId: mongoose.Schema.Types.ObjectId,
        fitDegree: Number  // degree of "fitting within the bubble"
    }],
    genre: String,  // Overall genre of this bubble e.g., "music", "comedy"
    // More AI-driven metric creation tools (eg., preferences, network, ,investorships and otherr network effect data)
    averageMintedTokens: Number,  // Average minted tokens of creators in this bubble
});

module.exports = mongoose.model('CreatorBubble', CreatorBubbleSchema);
