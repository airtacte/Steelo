const jwt = require('jsonwebtoken');
const { refreshTokenSecret, accessTokenSecret } = require('../config/config.js');

const tokenRefreshMiddleware = async (req, res, next) => {
    const refreshToken = req.headers['x-refresh-token'];
    const accessToken = req.headers['x-access-token'];

    if (!refreshToken || !accessToken) {
        return next();
    }

    try {
        jwt.verify(accessToken, accessTokenSecret, { ignoreExpiration: true });
    } catch (e) {
        return next();
    }

    try {
        const { userId } = jwt.verify(refreshToken, refreshTokenSecret);
        const newAccessToken = jwt.sign({ userId }, accessTokenSecret, { expiresIn: '1h' });

        res.setHeader('x-access-token', newAccessToken);
        next();
    } catch (e) {
        return next();
    }
};

module.exports = tokenRefreshMiddleware;