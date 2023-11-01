const TokenSchema = new mongoose.Schema({
    name: String,  // e.g., "$TEELO"
    price: Number,
    supply: Number,  // Total number of tokens
    fees: Number,  // Transaction fees or other relevant fees
    transactions: [String],  // Array of transaction IDs or references
    creatorId: mongoose.Schema.Types.ObjectId,  // Associate with a creator if it's a creator token
    historicalPrices: [{
        date: Date,
        price: Number
    }],
    forecastedPrices: [{
        date: Date,
        forecastedPrice: Number
    }],
    relatedMetrics: {
        userEngagement: Number,
        contentPerformance: Number
    }
});

module.exports = mongoose.model('Token', TokenSchema);
