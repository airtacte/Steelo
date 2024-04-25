const jwt = require("jsonwebtoken");
const generateToken = id => {
    return jwt.sign({ id }, "steelo", { expiresIn: '30d' });
};
module.exports = generateToken;
