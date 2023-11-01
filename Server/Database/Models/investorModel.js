const mongoose = require('mongoose');

const InvestmentActionSchema = new mongoose.Schema({
    actionType: String, // e.g., BUY, SELL, HOLD
    timestamp: Date,
    amount: Number,
    associatedToken: mongoose.Schema.Types.ObjectId,
    purchasePrice: Number,  // Price at which the token was purchased
    salePrice: Number,  // Price at which the token was sold (if applicable)
    fees: Number,  // Fees collected during the transaction
    profitOrLoss: Number  // Calculated as salePrice - purchasePrice - fees (if applicable)
});

const InvestorSchema = new mongoose.Schema({
    userId: mongoose.Schema.Types.ObjectId,
    investmentActions: [InvestmentActionSchema],
    portfolioMetrics: {
        tradingFrequency: Number,
        diversityScore: Number,
        valuationChange: Number,
        // Add more metrics as required
    }
});

module.exports = mongoose.model('Investor', InvestorSchema);