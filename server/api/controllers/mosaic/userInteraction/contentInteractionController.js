exports.likeContent = async (req, res) => {
    // Logic for liking content
    res.status(200).json({ message: 'Content liked successfully.' });
};
  
exports.commentOnContent = async (req, res) => {
    // Logic for commenting on content
    res.status(200).json({ message: 'Comment added successfully.' });
};