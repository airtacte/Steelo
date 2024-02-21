const InvestmentModel = require('../../models/InvestmentModel'); // Assuming you have an investments model. Adjust path accordingly.

exports.getUserInvestments = async (req, res) => {
    try {
        const userId = req.params.id;
        const investments = await InvestmentModel.find({ userId: userId });

        res.status(200).json(investments);
    } catch (error) {
        res.status(500).send('Server error.');
    }
};

