const mongoose = require("mongoose");
require("dotenv").config();
const DB_URI = process.env.MONGODB_URL;
mongoose.connect(DB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const db = mongoose.connection;
db.on("error", console.error.bind(console, "MongoDB connection error:"));
db.once("open", () => {
  console.log("Connected to MongoDB");
});
module.exports = db;
