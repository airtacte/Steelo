const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET;

exports.signToken = (payload) => {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
}

exports.verifyToken = (token) => {
    return jwt.verify(token, JWT_SECRET);
}
