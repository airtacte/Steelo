exports.addUserInvestment = async (req, res) => {
    try {
        const newInvestment = new InvestmentModel(req.body);
        const savedInvestment = await newInvestment.save();

        res.status(201).json(savedInvestment);
    } catch (error) {
        res.status(500).send('Server error.');
    }
};