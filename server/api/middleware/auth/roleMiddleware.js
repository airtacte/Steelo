const roleMiddleware = (roles) => (req, res, next) => {
    if (!roles.includes(req.user.role)) {
        const errorResponse = {
            status: 'error',
            message: 'Insufficient role privileges',
            details: {
                requiredRoles: roles,
                userRole: req.user.role,
                method: req.method,
                url: req.originalUrl,
                timestamp: new Date().toISOString(),
            },
        };

        return res.status(403).json(errorResponse);
    }

    next();
};

module.exports = roleMiddleware;