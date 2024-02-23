const express = require('express');
const investorDisplayController = require('../../controllers/profile/community/investorDisplayController');
const router = express.Router();

// Display investors
router.get('/profile/community/:id/investors', investorDisplayController.getInvestors);

module.exports = router;exports.getInvestorDetails = async (req, res) => {
    // Fetches details of a specific investor who has invested in the logged-in user.
    // ...
};
