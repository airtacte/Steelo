const jwt = require('jsonwebtoken');
let refreshTokens = []; // In a real-world scenario, consider storing these in a database.

exports.generateRefreshToken = (req, res) => {
    const refreshToken = jwt.sign({ username: req.user.username }, process.env.JWT_REFRESH_SECRET);
    refreshTokens.push(refreshToken);
    res.send(refreshToken);
};

exports.refreshAccessToken = (req, res) => {
    const refreshToken = req.body.token;
    if (!refreshToken || !refreshTokens.includes(refreshToken)) {
        return res.status(403).send('Refresh token is not valid.');
    }
    jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET, (err, user) => {
        if (err) return res.status(403).send('Invalid refresh token.');
        const newAccessToken = jwt.sign({ username: user.username }, process.env.JWT_SECRET);
        res.send(newAccessToken);
    });
};