const mongoose = require("mongoose");

const roomSchema = new mongoose.Schema({
  name: String,
  currentRoomHost: String,
  users: Array,
  _id: String,
});

const Room = mongoose.model("Room", roomSchema);

module.exports = Room;
