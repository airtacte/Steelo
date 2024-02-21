const Web3 = require('web3');

module.exports = (err, req, res, next) => {
    console.error(err); // Log the error for debugging purposes

    let statusCode = 500;
    let errorMessage = 'Internal Server Error';
    let errorDetails = {};

    // Replace Web3.errors.InvalidNumberOfParams, Web3.errors.InvalidConnection, and Web3.errors.TransactionError with the actual error classes we want to handle
    if (err instanceof Web3.errors.InvalidNumberOfParams) {
        statusCode = 400;
        errorMessage = 'Invalid number of parameters in the blockchain request';
        errorDetails = { message: err.message, stack: err.stack };
    } else if (err instanceof Web3.errors.InvalidConnection) {
        statusCode = 503;
        errorMessage = 'Blockchain service unavailable';
        errorDetails = { message: err.message, stack: err.stack };
    } else if (err instanceof Web3.errors.TransactionError) {
        statusCode = 400;
        errorMessage = 'Blockchain transaction error';
        errorDetails = { message: err.message, stack: err.stack };
    }

    // Define the error structure
    const errorResponse = {
        status: 'error',
        message: errorMessage,
        // Optionally include more detailed information in development mode
        ...(process.env.NODE_ENV === 'development' && errorDetails)
    };

    res.status(statusCode).json(errorResponse);
};