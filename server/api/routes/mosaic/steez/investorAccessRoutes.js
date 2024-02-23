const express = require('express');
const router = express.Router();
const investorAccessController = require('../../controllers/mosaic/steez/investorAccessController');

router.post('/grant', investorAccessController.grantInvestorAccess);
router.post('/revoke', investorAccessController.revokeInvestorAccess);

module.exports = router;