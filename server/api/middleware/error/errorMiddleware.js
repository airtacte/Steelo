module.exports = (err, req, res, next) => {
    console.error(err); // Log the error for debugging purposes

    // Define the error structure
    const errorResponse = {
        status: 'error',
        message: 'Internal Server Error',
        // Optionally include more detailed information in development mode
        ...(process.env.NODE_ENV === 'development' && { error: err.message, stack: err.stack })
    };

    // Check for specific types of errors to customize the response
    if (err.name === 'ValidationError') {
        // Example for handling validation errors
        errorResponse.message = err.message;
        errorResponse.details = err.details; // Assuming err.details contains validation error details
        return res.status(400).json(errorResponse);
    }

    // Add more conditions as needed to handle different types of errors

    // For unhandled errors, send a generic 500 Internal Server Error response
    return res.status(500).json(errorResponse);
};