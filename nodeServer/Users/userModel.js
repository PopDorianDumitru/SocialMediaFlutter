const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  username: String,
  name: String,
  email: String,
  passwordHash: String,
  fcm_token: Array,
  _id: String,
});

const User = mongoose.model("User", userSchema);

module.exports = User;
