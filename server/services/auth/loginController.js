const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const users = []; // This is a mock; replace with actual database calls.

exports.login = async (req, res) => {
  const { username, password } = req.body;
  const user = users.find((u) => u.username === username);
  if (!user) return res.status(400).send("Invalid username or password.");
  const validPassword = await bcrypt.compare(password, user.password);
  if (!validPassword)
    return res.status(400).send("Invalid username or password.");
  const token = jwt.sign({ username: user.username }, process.env.JWT_SECRET);
  res.send(token);
};