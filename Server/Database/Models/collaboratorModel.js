const mongoose = require('mongoose');

const CreatorSchema = new mongoose.Schema({
    name: String,
    role: String,
    investors: [String], // An array of investor IDs or references
    mintedTokens: Number,
    feesGenerated: Number,
    creativeStyle: String,  // e.g., "comedy", "education"
    genre: String,  // e.g., "music", "film"
    // ... other relevant fields...
});

module.exports = mongoose.model('Creator', CreatorSchema);