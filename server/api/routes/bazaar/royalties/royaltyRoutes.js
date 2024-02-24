const displayRoyaltiesRoutes = require('./api/routes/bazaar/royalties/displayRoyaltiesRoutes');
const royaltyRoutes = require('./api/routes/bazaar/royalties/royaltyRoutes');

// Middleware for user authorization
const authorize = (req, res, next) => {
    if (!req.user) {
      return res.status(403).send('You do not have permission to perform this action');
    }
    next();
};
  
  // Middleware for input validation
  const validateInput = (req, res, next) => {
    // Add your input validation logic here
    next();
};

app.use('/api/bazaar/royalties/display', authorize, displayRoyaltiesRoutes);
app.use('/api/bazaar/royalties/manage', authorize, royaltyRoutes);