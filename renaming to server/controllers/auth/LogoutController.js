exports.logout = (req, res) => {
    // Logic to invalidate token (if stored in-memory or in database)
    res.send('Logged out successfully.');
};