exports.getUserHistory = async (req, res) => {
    // Placeholder: Fetch user's interaction history
    res.json([{ id: 'view1', contentId: 'content123', timestamp: new Date() }]);
  };
  
  exports.clearHistory = async (req, res) => {
    // Placeholder: Clear user's interaction history
    res.send('User history cleared successfully');
  };  