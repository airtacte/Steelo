exports.grantInvestorAccess = async (req, res) => {
    // Logic to grant an investor access to specific Steez or investment opportunities
    res.status(200).json({ message: 'Investor access granted successfully.' });
};
  
exports.revokeInvestorAccess = async (req, res) => {
    // Logic to revoke an investor's access
    res.status(200).json({ message: 'Investor access revoked successfully.' });
};