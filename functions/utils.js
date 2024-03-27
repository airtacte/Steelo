const crypto = require('crypto');
const bcrypt = require('bcrypt');

function getNonceForUser() {
    return crypto.randomBytes(16).toString('hex');
}

async function hashPassword(password) {
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    return hashedPassword;
}

module.exports = { getNonceForUser, hashPassword };