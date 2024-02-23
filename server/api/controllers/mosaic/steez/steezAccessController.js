exports.getSteezDetails = async (req, res) => {
    // Logic to fetch and display Steez details
    res.status(200).json({ message: 'Steez details fetched successfully.' });
};
  
exports.transferSteez = async (req, res) => {
    // Logic for transferring Steez ownership
    res.status(200).json({ message: 'Steez transferred successfully.' });
};