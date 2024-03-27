const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

console.log(process.env.DB_USERNAME);
console.log(process.env.DB_PASSWORD);
// ... and so on for the rest

module.exports = {
  development: {
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    host: process.env.DB_HOST,
    dialect: process.env.DB_DIALECT,
  },
  // ... Other environments (test, production)
};
