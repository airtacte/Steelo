const displayRoyaltiesRoutes = require('./api/routes/bazaar/royalties/displayRoyaltiesRoutes');
const royaltyRoutes = require('./api/routes/bazaar/royalties/royaltyRoutes');

app.use('/api/bazaar/royalties/display', displayRoyaltiesRoutes);
app.use('/api/bazaar/royalties/manage', royaltyRoutes);