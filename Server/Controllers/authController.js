const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Mock user model - in a real application, this should be replaced with your database model
const users = [];

// Register a user
exports.register = async (req, res) => {
    const { username, password } = req.body;

    // Check if user exists
    const existingUser = users.find(u => u.username === username);
    if (existingUser) return res.status(400).send('User already registered.');

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Store user in the database (mock database for this example)
    const user = { username, password: hashedPassword };
    users.push(user);

    res.send('User registered successfully.');
};

// Login and generate JWT
exports.login = async (req, res) => {
    const { username, password } = req.body;

    // Find the user in the database
    const user = users.find(u => u.username === username);
    if (!user) return res.status(400).send('Invalid username or password.');

    // Check password
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) return res.status(400).send('Invalid username or password.');

    // Generate JWT
    const token = jwt.sign({ username: user.username }, process.env.JWT_SECRET);
    res.send(token);
};
