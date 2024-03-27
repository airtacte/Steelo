const bcrypt = require("bcryptjs");
const users = []; // This is a mock; replace with actual database calls.

exports.register = async (req, res) => {
  const { username, password } = req.body;
  const existingUser = users.find((u) => u.username === username);
  if (existingUser) return res.status(400).send("User already registered.");
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);
  const user = { username, password: hashedPassword };
  users.push(user);
  res.send("User registered successfully.");
};