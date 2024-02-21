const notFoundMiddleware = (req, res, next) => {
    const errorResponse = {
        status: 'error',
        message: 'Endpoint not found',
        details: {
            method: req.method,
            url: req.originalUrl,
            timestamp: new Date().toISOString(),
        },
    };

    res.status(404).json(errorResponse);
};

module.exports = notFoundMiddleware;