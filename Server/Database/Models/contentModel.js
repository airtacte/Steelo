const mongoose = require('mongoose');

const ContentSchema = new mongoose.Schema({
    title: String,
    description: String,
    format: String,  // e.g., "video", "audio", "image"
    type: String,  // e.g., "tutorial", "vlog"
    size: Number,  // in MB or other suitable unit
    exclusivity: Boolean,  // exclusive content or not
    viewCount: Number,
    comments: [String]  // An array of comments, consider creating a separate Comment model for scalability
    // ... other relevant fields...
});

module.exports = mongoose.model('Content', ContentSchema);