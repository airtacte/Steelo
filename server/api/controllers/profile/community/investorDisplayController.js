const express = require('express');
const InvestorDisplayService = require('../../../services/InvestorDisplayService'); // Assuming the path
const router = express.Router();

// Display investors
router.get('/:id', async (req, res) => {
    try {
        const investors = await InvestorDisplayService.getInvestors(req.params.id);
        res.json(investors);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

module.exports = router;exports.getInvestorDetails = async (req, res) => {
    // Fetches details of a specific investor who has invested in the logged-in user.
    // ...
};
