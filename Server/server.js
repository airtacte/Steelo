const express = require('express');
const app = express();
const userRoutes = require('./Routes/userRoutes');
const errorMiddleware = require('./Middleware/errorMiddleware');

app.use(express.json());
app.use('/api/users', userRoutes);
app.use(errorMiddleware);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server started on port ${PORT}`);
});
