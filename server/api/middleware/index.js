const authMiddleware = require('./auth/authMiddleware');
const roleMiddleware = require('./auth/roleMiddleware');
const tokenRefreshMiddleware = require('./auth/tokenRefreshMiddleware');
const errorMiddleware = require('./error/errorMiddleware');
const notFoundMiddleware = require('./error/notFoundMiddleware');
const validationErrorMiddleware = require('./error/validationErrorMiddleware');

module.exports = {
  authMiddleware,
  roleMiddleware,
  tokenRefreshMiddleware,
  errorMiddleware,
  notFoundMiddleware,
  validationErrorMiddleware,
};