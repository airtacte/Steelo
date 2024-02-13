const CreatorSchema = new mongoose.Schema({
    name: String,
    role: String,
    investors: [String],  // An array of investor IDs or references
    mintedTokens: Number,
    feesGenerated: Number,
    creativeStyle: String,  // e.g., "comedy", "education"
    genre: String,  // e.g., "music", "film"
    collaborations: [mongoose.Schema.Types.ObjectId], // list of collaborated creators
    historicalData: [{
        date: Date,
        mintedTokens: Number,
        growth: Number
    }],
    // ... other relevant fields...
});

module.exports = mongoose.model('Creator', CreatorSchema);
