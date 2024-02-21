const validationErrorMiddleware = (err, req, res, next) => {
    if (err instanceof SomeValidationError) { // Replace with your validation error class
        const errorResponse = {
            status: 'error',
            message: 'Validation failed',
            details: {
                errorDetails: err.details,
                method: req.method,
                url: req.originalUrl,
                timestamp: new Date().toISOString(),
            },
        };

        return res.status(400).json(errorResponse);
    }

    next(err); // Pass on to the next error handler
};

module.exports = validationErrorMiddleware;